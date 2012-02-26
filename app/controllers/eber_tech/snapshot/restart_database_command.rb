module EberTech
  module Snapshot
    class RestartDatabaseCommand < AbstractCommand
      def execute
        database.stop!(base_options)
        database.start!(base_options)
      end          
    end
  end
end
