module RackAttackAdmin
  class KeysController < RackAttackAdmin::ApplicationController
    def destroy
      orig_key = params[:id]
      unprefixed_key = Rack::Attack.unprefix_key(orig_key)
      Rack::Attack.cache.delete unprefixed_key
      redirect_to [rack_attack_admin, :rack_attack], success: "Deleted: #{unprefixed_key}"
    end
  end
end
