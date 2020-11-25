module RackAttackAdmin
  class ApplicationController < ActionController::Base
    skip_authorization_check  if respond_to? :skip_authorization_check
    before_action :require_admin, except: [:current_request]  if method_defined?(:require_admin)
    before_action :toggle_flags

    #═════════════════════════════════════════════════════════════════════════════════════════════════
    # Helpers

    def toggle_flags
      cookies[:skip_safelist] = params[:skip_safelist] if params[:skip_safelist]
    end

    helper_method \
    def is_redis?
      Rack::Attack.cache.store.to_s.match?(/Redis/)
    end

    helper_method \
    def redis
      return unless is_redis?
      store = Rack::Attack.cache.store
      store = store.redis if store.respond_to?(:redis)
      store = store.data  if store.respond_to?(:data)
      store
    end

    helper_method \
    def has_ttl?
      !!redis
    end

    helper_method \
    def current_request_rack_attack_stats
      req = Rack::Attack::Request.new(request.env)
      {
        blocklisted?:   Rack::Attack.blocklisted?(req),
        throttled?:     Rack::Attack.throttled?(req),
        safelisted?:    Rack::Attack.safelisted?(req),
        is_tracked?:    Rack::Attack.is_tracked?(req),
        skip_safelist?: req.skip_safelist?,
      }
    end
  end
end
