module RubbishCollection
  class RedbridgeAdapter
    DAYS = %w( SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY ).map(&:freeze).freeze

    def self.load
      require 'nokogiri'
    end

    def initialize local_authority
    end

    def collection_times_at postcode
      Net::HTTP.start "www.redbridge.gov.uk", 80 do |http|
        req = Net::HTTP::Get.new '/RecycleRefuse'
        req['Cookie'] = "RedbridgeIV3LivePref=postcode=#{postcode}"
        response = http.request req
        doc = Nokogiri::HTML response.body
        info = doc.xpath "//*[@id='RegularCollectionDay']"
        instructions = info.xpath ".//*[@class='instructions']/text()"
        hour, modifier = instructions.to_s.strip.scan(/(\d+)(am|pm)/)[0]
        hour = hour.to_i
        hour += 12 if modifier == "pm"
        time = hour * 100
        day = info.xpath ".//*[@class='day']/text()"
        day_index = DAYS.index day.to_s.strip
        [ CollectionTime.new(day_index, time) ]
      end
    end
  end
end

RubbishCollection.register_adapter 'http://mapit.mysociety.org/area/2497', RubbishCollection::RedbridgeAdapter
