# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pagoda-tunnel"

Gem::Specification.new do |s|
  s.name        = "pagoda-tunnel"
  s.version     = Pagoda::Tunnel::VERSION
  s.authors     = ["Lyon"]
  s.email       = ["lyon@delorum.com"]
  s.homepage    = ""
  s.summary     = %q{summary}
  s.description = %q{description}

  s.rubyforge_project = "pagoda-tunnel"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development
  s.add_development_dependency "rspec"


  # Production
  s.add_dependency "rest-client"


end
