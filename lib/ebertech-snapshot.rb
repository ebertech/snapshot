require 'rubygems'
require 'highline'
require 'rails/generators'
require 'clamp'
require 'fileutils'
# 
# dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "*.rb")
# Dir.glob(dir).each do |file|
#   require file
# end
# 
# dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "commands", "*.rb")
# Dir.glob(dir).each do |file|
#   require file
# end
# 
# dir = File.join(File.dirname(__FILE__), "ebertech", "snapshot", "generator", "*.rb")
# Dir.glob(dir).each do |file|
#   require file
# end
# 
# EberTech::Snapshot::Command::load_commands

require 'active_support'
require 'active_support/dependencies'
%w{models modules controllers}.each do |path|
  ActiveSupport::Dependencies.autoload_paths << File.expand_path(File.join("..", "..", "app", path), __FILE__)
end