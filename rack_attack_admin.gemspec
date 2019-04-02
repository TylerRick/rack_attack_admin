$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "rack_attack_admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rack_attack_admin"
  spec.version     = RackAttackAdmin::VERSION
  spec.authors     = [""]
  spec.email       = ["tyler@tylerrick.com"]
  spec.summary     = "Summary of RackAttackAdmin."
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
end
