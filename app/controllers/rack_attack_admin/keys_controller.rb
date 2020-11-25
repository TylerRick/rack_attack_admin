module RackAttackAdmin
  class KeysController < RackAttackAdmin::ApplicationController
    def destroy
      orig_key = params[:id]
      unprefixed_key = Rack::Attack.unprefix_key(orig_key)
      Rack::Attack.cache.delete unprefixed_key
      flash[:success] = "Deleted #{unprefixed_key}"
      redirect_to rack_attack_admin.root_path
    end
  end
end
