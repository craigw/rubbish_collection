module RubbishCollection

  class RushmoorAdapter

    def self.load
      require 'nokogiri'
      require 'date'
    end

    def initialize local_authority
    end

    def collection_times_at postcode, house_number
      Net::HTTP.start "www.rushmoor.gov.uk", 80 do |http|
        postcode = postcode.gsub("\s","") # Rushmoor don't like post codes with spaces
        req = Net::HTTP::Get.new "/article/1589/Address-search?housenumber=#{house_number}&addressdetail=#{postcode}"
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
          collection_type = case lines[1]
            when /rubbish bin collection/
              :domestic_refuse
            # In Rushmoor, recycling comes every two weeks, CollectionTime doesn't really support this
            # when /recycling collection/
            #   :domestic_recycling
            else
              next
          end
          day_index = Date::DAYNAMES.index(lines[2].strip.split(" ")[0])
          times << CollectionTime.new(day_index, :unknown, collection_type)
        end
        times
      end
    end
  end
end

RubbishCollection.register_adapter 'http://mapit.mysociety.org/area/2337', RubbishCollection::RushmoorAdapter
