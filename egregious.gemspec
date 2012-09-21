# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "egregious/version"

Gem::Specification.new do |s|
  s.name        = "egregious"
  s.version     = Egregious::VERSION
  s.authors     = ["Russell Edens"]
  s.email       = ["rx@voomify.com"]
  s.homepage    = "http://github.com/voomify/egregious"
  s.summary     = %q{Egregious is a rails based exception handling gem for well defined http exception handling for json, xml and html. Requires Rails 3.x.}
  s.description = %q{Egregious is a rails based exception handling gem for well defined http exception handling for json, xml and html. Requires Rails 3.x.}

  s.rubyforge_project = "egregious"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "json"
  s.add_development_dependency "hpricot"
  s.add_development_dependency "warden"
  s.add_development_dependency "cancan"

  s.add_runtime_dependency "rails", '>= 3.0.1'
  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "htmlentities"

end
