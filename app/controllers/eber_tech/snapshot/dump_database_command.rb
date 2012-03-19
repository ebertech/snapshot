module EberTech
  module Snapshot
    class DumpDatabaseCommand < AbstractCommand
      def execute
        database.dump(base_options)
      end          
    end
  end
end
