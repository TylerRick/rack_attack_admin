class Admin::RackAttack::KeysController < Admin::RackAttackController
  def destroy
    orig_key = params[:id]
    unprefixed_key = Rack::Attack.unprefix_key(orig_key)
    Rack::Attack.cache.delete unprefixed_key
    redirect_to [:admin, :rack_attack], success: "Deleted: #{unprefixed_key}"
  end
end
