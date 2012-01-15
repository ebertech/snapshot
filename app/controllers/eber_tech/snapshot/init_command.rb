module EberTech
  module Snapshot
    class InitCommand < Clamp::Command        
      def execute
        Database.create!
      end
    end
  end
end