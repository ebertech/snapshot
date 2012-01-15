# #!/bin/bash
# cd /usr/local/mysql && sudo bin/mysqladmin shutdown
module EberTech
  module Snapshot
    class StopDatabaseCommand < Clamp::Command
      def execute
        Database.current.stop!
      end          
    end
  end
end
