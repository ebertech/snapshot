module EberTech
  module Snapshot
    class PullCommand < AbstractCommand
      def execute
        database.pull!
      end       
    end
  end
end
