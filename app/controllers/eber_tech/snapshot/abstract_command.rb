module EberTech
  module Snapshot
    class AbstractCommand < ::Clamp::Command
      attr_accessor :database
      
      option "--dry-run", :flag, "Dry run"  
      option "--force", :flag, "Force the operation", :default => false
      
      def initialize(*args)
        super
        self.database = Configuration.new.database
      end
      
    end
  end
end