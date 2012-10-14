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
      raise "I don't know how to fetch times for #{local_authority.name} #{local_authority.map_it_id}"
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
    DAYS = %w( Sunday Monday Tuesday Wednesday Thursday Friday Saturday ).map(&:freeze).freeze

    attr_accessor :day
    private :day=, :day

    attr_accessor :time
    private :time=, :time

    attr_accessor :pickup_type
    private :pickup_type=, :pickup_type

    def initialize day, time = :unknown, pickup_type = :domestic_refuse
      self.day = day
      self.time = time
      self.pickup_type = pickup_type
    end

    def human_day
      DAYS[day]
    end

    def human_time
      return if time == :unknown
      t = time.to_s.rjust 4, '0'
      t[0..1] + ':' + t[2..3]
    end

    def human_type
      pickup_type.to_s.split(/_/).join(' ')
    end

    def to_s
      [ human_day, human_time ].compact.join(' ') + " - #{human_type}"
    end
  end

  def self.times_at_address address
    pc = address.postcode
    local_authority = LocalAuthority::LocalAuthority.find_by_postcode pc
    times = CollectionTimes.new
    return times if local_authority.nil?
    adaptor = adapter_for local_authority
    adaptor.collection_times_at(address).each do |t|
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
require 'rubbish_collection/southwark'
require 'rubbish_collection/rushmoor'
