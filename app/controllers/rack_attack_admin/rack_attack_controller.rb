load 'rack/attack_extensions.rb' if Rails.env.development?

module RackAttackAdmin
  class RackAttackController < RackAttackAdmin::ApplicationController
    # Web version of lib/tasks/rack_attack_admin_tasks.rake
    def index
      @default_banned_ip = Rack::Attack::BannedIp.new(bantime: '60 m')
      @counters_h = Rack::Attack.counters_h.with_indifferent_access.except(*Rack::Attack::BannedIps.keys)
      render
    end

    def current_request
      respond_to do |format|
        format.json do
          render json: current_request_rack_attack_stats
        end
        format.html
      end
    end
  end
end
