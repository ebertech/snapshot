# #!/bin/bash
# cd /usr/local/mysql && sudo bin/mysqladmin shutdown
# 
module EberTech
  module Snapshot
    class MigrateCommand < AbstractCommand
      def execute
        database.migrate!(base_options)
      end          
    end
  end
end
