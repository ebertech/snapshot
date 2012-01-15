module EberTech
  module Snapshot
    class PushCommand < Clamp::Command
      def execute
        Database.current.push!      
      end   
    end
  end
end
