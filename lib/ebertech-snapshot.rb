require 'rubygems'
require 'highline'
require 'git'
require 'clamp'
require 'fileutils'
require 'thor/group'
require 'ebertech-commandline'
require 'active_support'
require 'active_support/dependencies'

%w{models modules controllers}.each do |path|
  ActiveSupport::Dependencies.autoload_paths << File.expand_path(File.join("..", "..", "app", path), __FILE__)
end