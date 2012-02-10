# #!/bin/bash
# cd /usr/local/mysql && sudo bin/mysqladmin shutdown
module EberTech
  module Snapshot
    class StopDatabaseCommand < AbstractCommand
      def execute
        database.stop!(base_options)
      end          
    end
  end
end
