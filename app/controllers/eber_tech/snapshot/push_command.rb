module EberTech
  module Snapshot
    class PushCommand < AbstractCommand
      def execute
        database.push!      
      end   
    end
  end
end
