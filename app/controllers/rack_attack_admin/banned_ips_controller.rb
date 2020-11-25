# Inspired by: https://www.backerkit.com/blog/building-a-rackattack-dashboard/

module RackAttackAdmin
  class BannedIpsController < KeysController
    def create
      ban = Rack::Attack::BannedIp.new(
        params.require(Rack::Attack::BannedIp.model_name.param_key).
          permit(:ip, :bantime)
      )
      case ban.bantime
      when /m$/
        ban.bantime = ban.bantime.to_i * ActiveSupport::Duration::SECONDS_PER_MINUTE
      when /h$/
        ban.bantime = ban.bantime.to_i * ActiveSupport::Duration::SECONDS_PER_HOUR
      when /d$/
        ban.bantime = ban.bantime.to_i * ActiveSupport::Duration::SECONDS_PER_DAY
      else
        ban.bantime = ban.bantime.to_i
      end
      if ban.valid?
        Rack::Attack::BannedIps.ban! ban.ip, ban.bantime
        flash[:success] = "Added #{ban.ip}"
      else
        flash[:alert] = "Failed to add: #{ban.errors.full_messages.join('. ')}"
      end
      redirect_to rack_attack_admin.root_path
    end
  end
end
