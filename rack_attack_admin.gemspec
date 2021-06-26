
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack_attack_admin/version"

Gem::Specification.new do |spec|
  spec.name          = 'rack_attack_admin'
  spec.version       = RackAttackAdmin.version
  spec.authors       = ['Tyler Rick']
  spec.email         = ['tyler@tylerrick.com']
  spec.license       = 'MIT'

  spec.summary       = %q{A Rack::Attack admin dashboard}
  spec.description   = %q{Lets you see the current state of all throttles and bans. Delete existing keys/bans. Manually add bans.}
  spec.homepage      = 'https://github.com/TylerRick/rack_attack_admin'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.metadata['source_code_uri']}/blob/master/Changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'
  spec.add_dependency 'activesupport', '>= 4.2'
  spec.add_dependency 'activesupport-duration-human_string', '>= 0.1.1'
  spec.add_dependency 'haml'
  spec.add_dependency 'memoist'
  spec.add_dependency 'rack-attack'
  spec.add_dependency 'rails', '>= 4.2'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
