module RubbishCollection
  class SouthwarkAdapter
    DAYS = %w( Sunday Monday Tuesday Wednesday Thursday Friday Saturday ).map(&:freeze).freeze

    def self.load
      require 'nokogiri'
    end

    def initialize local_authority
    end

    def collection_times_at postcode
      Net::HTTP.start "wasteservices.southwark.gov.uk", 80 do |http|
        req = Net::HTTP::Get.new "/findAddress.asp?pc=#{postcode.gsub(/\s+/, '')}"
        response = http.request req
        addresses = Nokogiri::HTML.fragment response.body
        first_address = addresses.xpath(".//option").detect { |o| o['value'].to_s.strip != '' }
        uprn = first_address['value'].to_s
        req = Net::HTTP::Get.new "/findSummary.asp?uprn=#{uprn}"
        response = http.request req
        times = []
        response.body.split(/<br><br><br><br>/).each do |fragment|
          fragment_doc = Nokogiri::HTML.fragment fragment
          link = fragment_doc.at_xpath('.//a')
          link_text = link.inner_text.to_s.strip
          collection_type = case link_text
          when /refuse bin/
            :domestic_refuse
          when /communal recycling bins/
            :communal_recycling
          when /mixed recycling bag/
            :mixed_recycling_bag
          else
            link_text.to_sym
          end
          DAYS.inject([]) { |a,e|
            a << DAYS.index(e) if fragment =~ /#{e}/i
            a
          }.each do |d|
            t = CollectionTime.new d, :unknown, collection_type
            times << t
          end
        end
        times
      end
    end
  end
end

RubbishCollection.register_adapter 'http://mapit.mysociety.org/area/2491', RubbishCollection::SouthwarkAdapter
