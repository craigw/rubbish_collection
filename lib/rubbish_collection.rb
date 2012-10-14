require "rubbish_collection/version"
require 'local_authority'

module RubbishCollection
  class UnknownAdapter
    attr_accessor :local_authority
    private :local_authority=, :local_authority

    def initialize local_authority
      self.local_authority = local_authority
    end

    def collection_times_at postcode
      raise "I don't know how to fetch times for #{local_authority.name}"
    end
  end

  class CollectionTimes
    attr_accessor :times
    private :times=, :times

    def initialize
      self.times = []
    end

    def each
      times.each { |t| yield t }
    end
    include Enumerable

    def << time
      times << time
    end
  end

  class CollectionTime
    DAYS = %w( Sunday Monday Tuesday Wednesday thursday Friday Saturday ).map(&:freeze).freeze

    attr_accessor :day
    private :day=, :day

    attr_accessor :time
    private :time=, :time

    def initialize day, time
      self.day = day
      self.time = time
    end

    def human_day
      DAYS[day]
    end

    def human_time
      t = time.to_s.rjust 4, '0'
      t[0..1] + ':' + t[2..3]
    end

    def to_s
      "#{human_day} #{human_time}"
    end
  end

  def self.times_at_postcode postcode
    times = CollectionTimes.new
    local_authority = LocalAuthority::LocalAuthority.find_by_postcode postcode
    return times if local_authority.nil?
    adaptor = adapter_for local_authority
    adaptor.collection_times_at(postcode).each do |t|
      times << t
    end
    times
  end

  def self.adapters
    @@adapters ||= Hash.new UnknownAdapter
  end

  def self.adapter_for local_authority
    adapter = adapters[local_authority.map_it_id]
    adapter.load if adapter.respond_to? :load
    adapter.new local_authority
  end

  def self.register_adapter map_it_id, adapter
    adapters[map_it_id] = adapter
  end
end

require 'rubbish_collection/redbridge'
