# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ebertech-snapshot/version"

Gem::Specification.new do |s|
  s.name        = "ebertech-snapshot"
  s.version     = Ebertech::Snapshot::VERSION
  s.authors     = ["Andrew Eberbach"]
  s.email       = ["andrew@ebertech.ca"]
  s.homepage    = ""
  s.summary     = "Save the database into a git-managed snapshot"
  s.description = "Save the database into a git-managed snapshot"

  s.rubyforge_project = "ebertech-snapshot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency  "git"
  s.add_runtime_dependency  "activesupport"
  s.add_runtime_dependency  "ebertech-commandline"
  s.add_runtime_dependency "rake"
end