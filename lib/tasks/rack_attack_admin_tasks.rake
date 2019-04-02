begin
  require 'terminal-table'
rescue LoadError
  puts "You must `gem install terminal-table` in order to use the rake tasks in #{__FILE__}"
end

namespace :rack_attack_admin do
  def clear
    puts "\e[H\e[2J"
  end

  desc "Watch the internal state of Rack::Attack. Similar to /admin/rack_attack but auto-refreshes, and shows previous value if there was a change. (Mostly useful in dev where there aren't many keys and they don't change very often.)"
  task :watch do
    interval = ENV['interval']&.to_i || 1

    curr_h = {}
    prev_h = {}
    prev_h_s_ago = 0

    curr_banned = []
    prev_banned = []
    prev_banned_s_ago = 0

    loop do
      clear

      if curr_banned != Rack::Attack::Fail2Ban.banned_ip_keys
        prev_banned = curr_banned
        prev_banned_s_ago = 0
        curr_banned = Rack::Attack::Fail2Ban.banned_ip_keys
      end

      if curr_h != Rack::Attack.counters_h
        prev_h = curr_h
        prev_h_s_ago = 0
        curr_h = Rack::Attack.counters_h
      end

      puts Terminal::Table.new(
        headings: ['Banned IP', "Previous (#{prev_h_s_ago} s ago)"],
        rows: [].tap { |rows|
          while (
            row = [
              curr_banned.shift,
              prev_banned.shift
            ]
            row.any?
          ) do
            row = row.map {|key| key && Rack::Attack.humanize_key(key) }
            rows << row
          end
        }
      )

      keys = (
        curr_h.keys |
        prev_h.keys
      )
      rows = keys.map do |key|
        [
          "%-80s" % Rack::Attack.humanize_key(key),
          curr_h[key],
          prev_h[key],
        ]
      end
      puts Terminal::Table.new(
        headings: ['Key', 'Current Count', "Previous (#{prev_h_s_ago} s ago)"],
        rows: rows
      )

      sleep interval
      prev_h_s_ago      += interval
      prev_banned_s_ago += interval
    end
  end
end
