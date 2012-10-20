require "rubbish_collection/version"
require 'local_authority'
require 'runt'

module RubbishCollection
  DOMESTIC_RUBBISH = 'Domestic Rubbish'.freeze
  DOMESTIC_RECYCLING = 'Domestic Recycling'.freeze
  COMMUNAL_RECYCLING = 'Communal Recycling'.freeze

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

  class Collections
    attr_accessor :collections
    private :collections=, :collections

    def initialize
      self.collections = []
    end

    def << collection
      collections << collection
    end

    def each
      upto(Time.now + (86400 * 31)).each { |t| yield t }
    end
    include Comparable

    def upto until_date
      now = Time.now
      collections.map { |c| c.realise now, until_date }.flatten.sort
    end
  end

  class Resolution
    attr_accessor :name
    private :name=

    attr_accessor :step
    private :step=

    def initialize name, step
      self.name = name
      self.step = step
    end

    def <=> other
      other.step <=> step
    end
    include Comparable

    def match_resolution time
      args = [ time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec ]
      case step
      when 1
        Runt::PDate.sec *args
      when 60
        Runt::PDate.min *args
      when 3600
        Runt::PDate.hour *args
      when 86400
        Runt::PDate.day *args
      else
        raise "Don't know how to represent a time with resolution of #{step}"
      end
    end

    SECOND = new "Second", 1
    MINUTE = new "Minute", 60
    HOUR = new "Hour", 3600
    DAY = new "Day", 86400
  end

  class Schedule
    attr_accessor :condition
    private :condition=, :condition

    attr_accessor :resolution
    private :resolution=

    def initialize resolution
      self.resolution = resolution
    end

    def self.day_of_week day_name
      normalised_name = day_name[0,1].upcase + day_name[1..-1].downcase
      day_const = Runt.const_get normalised_name
      Runt::DIWeek.new day_const
    end

    def self.hour hour
      Runt::REDay.new hour, 0, hour, 59, true
    end

    def add_rule rule
      if condition.nil?
        self.condition = rule
        return
      end
      self.condition = condition & rule
    end

    def include? time
      time_with_resolution = resolution.match_resolution time
      condition.include? time_with_resolution
    end

    def to_s
      condition.to_s
    end
  end

  class Collection
    attr_accessor :pickup_type
    private :pickup_type=

    attr_accessor :schedule
    private :schedule=, :schedule

    def initialize pickup_type, schedule
      self.pickup_type = pickup_type
      self.schedule = schedule
    end

    def realise from, to
      times = []
      now = from
      resolution = schedule.resolution
      rem = now.to_i % resolution.step
      diff = resolution.step - rem
      now += diff
      while now < to
        if schedule.include? now
          time = CollectionTime.new pickup_type, now, resolution
          times << time
        end
        now += resolution.step
      end
      times
    end

    def to_s
      [ pickup_type, schedule.to_s ].join ' - '
    end
  end

  class CollectionTime
    attr_accessor :time
    private :time=, :time

    attr_accessor :resolution
    private :resolution=, :resolution

    attr_accessor :pickup_type
    private :pickup_type=, :pickup_type

    def initialize pickup_type, time, resolution
      self.time = time
      self.resolution = resolution
      self.pickup_type = pickup_type
    end

    def human_time
      return unless resolution > Resolution::DAY
      start_time = time
      end_time = time + resolution.step

      [ start_time, end_time ].map { |t| t.strftime('%l.%M%P').strip }.join(' to ')
    end

    def human_date
      time.strftime '%A %d %B %Y'
    end

    def human_type
      pickup_type
    end

    def <=> other
      sort_key <=> other.sort_key
    end

    def sort_key
      [ time, resolution, pickup_type ]
    end

    def to_s
      [ human_date, human_time ].compact.join(' from ') + " - #{human_type}"
    end
  end

  def self.times_at_address address
    pc = address.postcode
    local_authority = LocalAuthority::LocalAuthority.find_by_postcode pc
    times = Collections.new
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
