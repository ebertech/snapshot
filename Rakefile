begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "snapshot.ebertech.ca"
    gemspec.summary = "Save the database into a git-managed snapshot"
    gemspec.email = "andrew@ebertech.ca"
    gemspec.authors = ["Andrew Eberbach"]
    gemspec.executables = ["snapshot"]
    gemspec.files = Dir["lib/**/*.rb", "VERSION", "generators/**/*.rb", "generators/**/*.yml"]
    gemspec.add_dependency  "daemons"
    gemspec.add_dependency  "highline"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
