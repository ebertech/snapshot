# #!/bin/bash
# cd /usr/local/mysql && sudo bin/mysqladmin shutdown
# 
module EberTech
  module Snapshot
    class MigrateCommand < Clamp::Command
      def execute
        Database.current.migrate!
      end          
    end
  end
end
