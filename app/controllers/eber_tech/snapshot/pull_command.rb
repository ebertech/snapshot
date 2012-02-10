module EberTech
  module Snapshot
    class PullCommand < AbstractCommand
      def execute
        database.pull!(base_options)
      end       
    end
  end
end
