module EberTech
  module Snapshot
    class PullCommand < Clamp::Command
      def execute
        Database.current.pull!
      end       
    end
  end
end
