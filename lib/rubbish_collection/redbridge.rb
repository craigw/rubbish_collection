module RubbishCollection
  class RedbridgeAdapter
    DAYS = %w( SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY ).map(&:freeze).freeze

    def self.load
      require 'nokogiri'
    end

    def initialize local_authority
    end

    def collection_times_at address
      Net::HTTP.start "www.redbridge.gov.uk", 80 do |http|
        req = Net::HTTP::Get.new '/RecycleRefuse'
        req['Cookie'] = "RedbridgeIV3LivePref=postcode=#{address.postcode}"
        response = http.request req
        doc = Nokogiri::HTML response.body
        info = doc.xpath "//*[@id='RegularCollectionDay']"
        instructions = info.xpath ".//*[@class='instructions']/text()"
        hour, modifier = instructions.to_s.strip.scan(/(\d+)(am|pm)/)[0]
        hour = hour.to_i
        hour += 12 if modifier == "pm"
        time = hour * 100
        day_name = info.xpath(".//*[@class='day']/text()").to_s
        s = Schedule.new Resolution::HOUR
        s.add_rule Schedule.day_of_week day_name
        s.add_rule Schedule.hour hour
        [ Collection.new(DOMESTIC_RUBBISH, s) ]
      end
    end
  end
end

RubbishCollection.register_adapter 'http://mapit.mysociety.org/area/2497', RubbishCollection::RedbridgeAdapter
