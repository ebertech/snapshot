require 'fileutils'
require 'highline'


dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "*.rb")
Dir.glob(dir).each do |file|
  require file
end

dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "commands", "*.rb")
Dir.glob(dir).each do |file|
  require file
end

EberTech::Snapshot::Command::load_commands