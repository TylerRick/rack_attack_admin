module RackAttackAdmin
  class KeysController < RackAttackAdmin::ApplicationController
    def destroy
      orig_key = params[:id]
      unprefixed_key = Rack::Attack.unprefix_key(orig_key)
      Rack::Attack.cache.delete unprefixed_key
      redirect_to root_path, success: "Deleted: #{unprefixed_key}"
    end
  end
end
