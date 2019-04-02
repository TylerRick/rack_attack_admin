require 'memoist'
require 'active_model'

ActiveSupport::Duration.class_eval do
  # Returns a concise and human-readable string, like '3h' or '3h 5m 7s'
  # This is unlike #to_s, which is concise but not very human-readable (gives time in seconds even for large durations),
  # This is unlike #iso8601, which is concise but not very human-readable ("P3Y6M4DT12H30M5S").
  def human_to_s
    iso8601.
      sub('P', '').
      sub('T', '').
      downcase.
      gsub(/
        # We only want to pad all *except* the first "\d\D" part
        (\D+)  # Preceeded by: a non-digit
        (\d+)  # A digit
      /x) { '%s%02d' % [$1, $2.to_i] }.
      gsub(/
        \D    # Not a digit
        (?!$) # Not at end
      /x) { |m| "#{m} " }
  end
end

      Rack::Attack
class Rack::Attack
  class << self
    extend Memoist

    def prefixed_keys
      cache.store.keys.grep(/^rack::attack:/)
    end

    # AKA unprefixed_keys
    def keys
      prefixed_keys.map { |key|
        unprefix_key(key)
      }
    end

    def unprefix_key(key)
      key.sub "#{cache.prefix}:", ''
    end

    def to_h
      keys.each_with_object({}) do |k, h|
        h[k] = cache.store.read(k)
      end
    end

    def counters_h
      (keys - Fail2Ban.banned_ip_keys).each_with_object({}) do |unprefixed_key, h|
        h[unprefixed_key] = cache.read(unprefixed_key)
      end
    end

    def ip_from_key(key)
      key.match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)&.to_s
    end

    def humanize_h(h)
      h.transform_keys do |key|
        humanize_key(key)
      end
    end

    # Reverse Cache#key_and_expiry:
    #   … "#{prefix}:#{(@last_epoch_time / period).to_i}:#{unprefixed_key}" …
    def _parse_key(unprefixed_key)
      unprefixed_key.match(
        /\A
            (?<time_bucket>\d+) # 1 or more digits
            # In the case of 'fail2ban:count:local_name', want name to onlybe 'local_name'
            (?::(?:fail|allow)2ban:count)?:(?<name>.+)
            :(?<discriminator>[^:]+)
        \Z/x
      )
    end

    class ParsedKey
    end

    # Reverse Cache#key_and_expiry:
    #   … "#{prefix}:#{(@last_epoch_time / period).to_i}:#{unprefixed_key}" …
    # @return [Hash]
    #   :time_bucket [Number]: The raw time bucket (Time.now / period), like 5180595
    #   :name [String]: The name of the rule, as passed to `throttle`, `def_fail2ban`, etc.
    #   :discriminator [String]: A discriminator such as a specific IP address.
    #   :time_range [Range]:
    #     (If we have enough information to calculate) A Range, like Time('12:35')..Time('12:40').
    #     This Range has an extra duration method that returns a ActiveSupport::Duration representing
    #     the duration of the period.
    def parse_key(unprefixed_key)
      match = _parse_key(unprefixed_key)
      return unless match
      match.named_captures.with_indifferent_access.tap do |hash|
        hash[:rule] = rule = find_rule(hash[:name])
        if (
          hash[:time_bucket] and
          rule and
          rule.respond_to?(:period)
        )
          hash[:time_range] = rule.time_range(hash[:time_bucket])
        end
      end
    end

    def time_bucket_from_key(unprefixed_key)
      _parse_key(unprefixed_key)&.[](:time_bucket)
    end

    def name_from_key(unprefixed_key)
      _parse_key(unprefixed_key)&.[](:name)
    end

    def discriminator_from_key(unprefixed_key)
      _parse_key(unprefixed_key)&.[](:discriminator)
    end

    def time_range(unprefixed_key)
      parse_key(unprefixed_key)&.[](:time_range)
    end

    def find_rule(name)
      throttles[name] ||
      blocklists[name] ||
      fail2bans[name]
    end

    # Transform
    #   rack::attack:5179628:req/ip:127.0.0.1
    # into something like
    #   throttle('req/ip'):127.0.0.1
    # so you can see which period it was for and what the limit for that period was.
    # Would have to look up the rules stored in Rack::Attack.
    def humanize_key(key)
      key = unprefix_key(key)
      match = parse_key(key)
      return key unless match

      name = match[:name]
      rule = find_rule(name)
      rule_type = rule.type if rule
      "#{rule_type}('#{name}'):#{match[:discriminator]}"
    end

    # Unlike the provided #tracked?, this returns a boolean which is only true if one of the tracks
    # matches. (The provided tracked? just returns the array of `tracks`.)
    def is_tracked?(request)
      tracks.any? do |_name, track|
        track.matched_by?(request)
      end
    end
  end # class << self

  module PeriodIntrospection
    # time_bucket is epoch_time / period
    def time_range(time_bucket)
      time_bucket = time_bucket.to_i
      start_time = Time.at(time_bucket * period)
      end_time   = Time.at(start_time  + period)
      duration   = ActiveSupport::Duration.build(end_time - start_time)

      (start_time .. end_time).tap do |time_range|
        # @return [ActiveSupport::Duration]
        time_range.define_singleton_method :duration do
          duration
        end
      end
    end
  end

  module InspectWithOptions
    def options
      {}
    end

    # throttle('req/ip', limit: 300, period: 1.minute)
    def inspect_with_options
      "#{type}('#{name}', #{options.inspect})"
    end
  end

  class Throttle
    include PeriodIntrospection
    include InspectWithOptions

    def options
      {
        period: period,
        limit:  limit,
      }
    end
  end


  class << self
    def fail2bans;  @fail2bans  ||= {}; end

    def def_fail2ban(name, options)
      self.fail2bans[name] = Fail2Ban.new( name, options.merge(type: :fail2ban))
    end
    def def_allow2ban(name, options)
      self.fail2bans[name] = Allow2Ban.new(name, options.merge(type: :allow2ban))
    end

    def fail2ban(name, discriminator, klass: Fail2Ban, &block)
      instance = fail2bans[name] or raise "could not find a fail2ban rule named '#{name}'; make sure you define with def_fail2ban/def_allow2ban first"
      klass.filter(
        "#{name}:#{discriminator}",
        findtime: instance.period,
        maxretry: instance.limit,
        bantime:  instance.bantime,
        &block
      )
    end

    def allow2ban(name, discriminator, &block)
      fail2ban(name, discriminator, klass: Allow2Ban, &block)
    end
  end

  # Make it instantiable like Throttle so we can introspect it
  module InstantiableFail2Ban
    MANDATORY_OPTIONS = [:limit, :period, :type].freeze

    attr_reader :name, :limit, :period, :bantime, :type
    def initialize(name, options)
      @name = name
      MANDATORY_OPTIONS.each do |opt|
        raise ArgumentError.new("Must pass #{opt.inspect} option") unless options[opt]
      end
      @limit   = options[:limit]
      @period  = options[:period].respond_to?(:call) ? options[:period] : options[:period].to_i
      @bantime = options[:bantime]   or raise ArgumentError, "Must pass bantime option"
      @type    = options[:type]
    end

    include PeriodIntrospection
    include InspectWithOptions

    def options
      {
        period: period,
        limit:  limit,
      }
    end
  end

  class Fail2Ban
    include InstantiableFail2Ban

    class << self
      def prefixed_keys
        cache.store.keys.grep(/^#{cache.prefix}:(allow|fail)2ban:/)
      end

      # AKA unprefixed_keys
      # Removes the Rack::Attack.cache.prefix, but not 'allow2ban'
      def keys
        prefixed_keys.map { |key|
          Rack::Attack.unprefix_key(key)
        }
      end

      def to_h
        keys.each_with_object({}) do |k, h|
          h[k] = cache.store.read(k)
        end
      end

      def banned_ip_keys
        keys.grep(/(allow|fail)2ban:ban:/)
      end

      def full_key_prefix
        "#{cache.prefix}:#{key_prefix}"
      end
    end
  end

  class BannedIp
    include ActiveModel::Model
    include ActiveModel::Validations
    #include ActiveModel::Attributes

    attr_accessor :ip
    attr_accessor :bantime
    #attribute :bantime, :number

    validates :ip, :bantime, presence: true
  end

  class BannedIps
    class << self
      def prefixed_keys
        cache.store.keys.grep(/^#{full_key_prefix}:/)
      end

      # Removes only the Rack::Attack.cache.prefix
      def keys
        prefixed_keys.map { |key|
          Rack::Attack.unprefix_key(key)
        }
      end

      def ips
        prefixed_keys.map { |key|
          ip_from_key(key)
        }
      end

      def ban!(ip, bantime)
        cache.write("#{key_prefix}:#{ip}", 1, bantime)
      end

      def banned?(ip)
        cache.read("#{key_prefix}:#{ip}") ? true : false
      end

      def ip_from_key(key)
        key = Rack::Attack.unprefix_key(key)
        key.sub "#{key_prefix}:", ''
      end

      def full_key_prefix
        "#{cache.prefix}:#{key_prefix}"
      end

    protected

      def key_prefix
        'banned_ips'
      end

    private

      def cache
        Rack::Attack.cache
      end
    end
  end

  class Request
    extend Memoist

    memoize \
      def headers
        env.
          select { |k,v| k.start_with? 'HTTP_'}.
          transform_keys { |k| k.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-') }.
          sort.to_h.
          tap do |headers|
          headers.define_singleton_method :[] do |k|
            super(k.split(/[-_]/).map(&:capitalize).join('-'))
          end
        end
    end
  end
end
