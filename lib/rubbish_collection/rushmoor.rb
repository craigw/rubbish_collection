module RubbishCollection

  class RushmoorAdapter

    def self.load
      require 'nokogiri'
      require 'date'
    end

    def initialize local_authority
    end

    def collection_times_at address
      Net::HTTP.start "www.rushmoor.gov.uk", 80 do |http|
        postcode = address.postcode.gsub("\s","") # Rushmoor don't like post codes with spaces
        req = Net::HTTP::Get.new "/article/1589/Address-search?housenumber=#{address.house_number}&addressdetail=#{postcode}"
        response = http.request req
        if response.code == "302"
          response = Net::HTTP.get_response(URI.parse(response.header['location']))
        end
        doc = Nokogiri::HTML response.body
        info = doc.xpath("//*[@id='inmyarea']")
        container = info.xpath("//*[@class='ima_block']").first
        times = []
        container.xpath("p").each do |rubbish_div|
          lines = rubbish_div.text.split("\n")
          day_name = lines[2].to_s.strip.split(" ")[0]
          s = Schedule.new Resolution::DAY
          collection = case lines[1]
          when /rubbish bin collection/
            s.add_rule Schedule.day_of_week day_name
            Collection.new DOMESTIC_RUBBISH, s
          when /recycling collection/
            nc = Time.parse lines[2]
            start_date = Runt::PDate.day nc.year, nc.month, nc.day
            s.add_rule Runt::EveryTE.new(start_date, 2, Runt::DPrecision::WEEK)
            s.add_rule Schedule.day_of_week day_name
            Collection.new DOMESTIC_RECYCLING, s
          else
            next
          end
          times << collection
        end
        times
      end
    end
  end
end

RubbishCollection.register_adapter 'http://mapit.mysociety.org/area/2337', RubbishCollection::RushmoorAdapter
