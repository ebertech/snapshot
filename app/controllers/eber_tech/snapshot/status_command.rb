module EberTech
  module Snapshot
    class StatusCommand < AbstractCommand
      def execute
        if database.print_status(base_options)
          exit 0
        else
          exit 1
        end
      end          
    end
  end
end
