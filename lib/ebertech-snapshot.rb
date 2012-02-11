require 'rubygems'
require 'highline'
require 'git'
require 'clamp'
require 'fileutils'
require 'thor/group'
require 'ebertech-commandline'
require 'rake'
require 'yaml'
require 'active_support'
require 'active_support/dependencies'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/delegation.rb'

%w{models modules controllers}.each do |path|
  if ActiveSupport::Dependencies.respond_to?(:autoload_paths)
    ActiveSupport::Dependencies.autoload_paths << File.expand_path(File.join("..", "..", "app", path), __FILE__)
  else
    ActiveSupport::Dependencies.load_paths << File.expand_path(File.join("..", "..", "app", path), __FILE__)
  end
end

Git::Base.class_eval do
  def clean
     self.lib.clean
  end
  def remove_tag(tag)
     self.lib.remove_tag(tag)
  end  
end

Git::Lib.class_eval do
  def clean
    command('clean', ["-d","-f"])
  end
  def remove_tag(tag)
     command('tag', ["-d", tag])
  end  
end
  

