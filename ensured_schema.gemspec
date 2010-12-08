# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ensured_schema/version"

Gem::Specification.new do |s|
  s.name        = "ensured_schema"
  s.version     = EnsuredSchema::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Conley"]
  s.email       = ["chris@chrisconley.me"]
  s.homepage    = "http://rubygems.org/gems/ensured_schema"
  s.summary     = %q{Ensures database schema always matches your schema.rb file}
  s.description = %q{Smarter migrations}

  s.add_dependency('activerecord', '~> 2.3.5')

  s.add_development_dependency('mocha', '~> 0.9.8')

  s.rubyforge_project = "ensured_schema"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
