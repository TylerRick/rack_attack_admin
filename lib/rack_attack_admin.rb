# TODO: Figure out why renaming it to be this (consistent) path causes it to not load
# config/routes.rb and to not add routes even if we force it to be loaded.
#require "rack_attack_admin/engine"
require "attack_admin/engine"

require_relative 'rack/attack_extensions'

module RackAttackAdmin
end
