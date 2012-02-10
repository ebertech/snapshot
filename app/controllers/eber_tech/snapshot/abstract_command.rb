module EberTech
  module Snapshot
    class AbstractCommand < ::Clamp::Command
      attr_accessor :database
      
      option "--dry-run", :flag, "Dry run"  
      
      def initialize(*args)
        super
        self.database = Configuration.new.database
      end
      
    end
  end
end