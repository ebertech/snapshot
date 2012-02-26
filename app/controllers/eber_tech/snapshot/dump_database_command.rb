module EberTech
  module Snapshot
    class DumpDatabaseCommand < AbstractCommand
      def execute
        puts database.dump(base_options)
      end          
    end
  end
end
