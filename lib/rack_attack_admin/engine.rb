module RackAttackAdmin
  class Engine < ::Rails::Engine
    isolate_namespace RackAttackAdmin
  end
end

# TODO: Why is this needed?
require_relative '../../config/routes'
