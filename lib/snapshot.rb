require 'rubygems'
require 'highline'
require 'bundler/setup'
require 'rails/generators'

require 'fileutils'

dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "*.rb")
Dir.glob(dir).each do |file|
  require file
end

dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "commands", "*.rb")
Dir.glob(dir).each do |file|
  require file
end

dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "generator", "*.rb")
Dir.glob(dir).each do |file|
  require file
end

EberTech::Snapshot::Command::load_commands