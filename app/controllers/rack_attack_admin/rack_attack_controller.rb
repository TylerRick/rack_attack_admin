load 'rack/attack_extensions.rb' if Rails.env.development?

module RackAttackAdmin
  class RackAttackController < RackAttackAdmin::ApplicationController
    # Web version of lib/tasks/rack_attack_admin_tasks.rake
    def index
      @default_banned_ip = Rack::Attack::BannedIp.new(bantime: '60 m')
      @banned_ip_keys = Rack::Attack::Fail2Ban.banned_ip_keys
      @counters_h     = Rack::Attack.counters_h.
        without(*Rack::Attack::BannedIps.keys)
      render
    end

    def current_request
      render json: current_request_rack_attack_stats
    end
  end
end
