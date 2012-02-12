module EberTech
  module Snapshot
    class StatusCommand < AbstractCommand
      def execute
        database.print_status(base_options)
      end          
    end
  end
end
