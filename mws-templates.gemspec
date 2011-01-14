# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "mws-templates"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Balazs Nagy"]
  s.email       = ["julsevern@gmail.com"]
  s.homepage    = "https://github.com/julian7/mws-templates"
  s.summary     = %q{Rails 3 templates we use at Magic Workshop}
  s.description = %q{Templates to create default layout, deployment scripts we use.}

  s.rubyforge_project = s.name

  s.files         = Dir["{lib,spec,features}/**/*", "[A-Z]*"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '~> 3.0.0'
end
