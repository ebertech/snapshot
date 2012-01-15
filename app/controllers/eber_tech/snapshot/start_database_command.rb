# #!/bin/bash
# cd /usr/local/mysql && sudo -u _mysql bin/mysqld_safe --datadir=/usr/local/mysql/data2/ &
# 
# for i in `seq 1 100`; do
#  if mysqladmin status >/dev/null 2>&1; then
#      exit 0
#  fi
# done
# exit 1
# # /usr/local/mysql/bin/mysqld_safe --datadir=/Users/ame/Desktop/data -P 3307 --pid-file=$PWD/pidfile #--general-log-file=/Users/ame/Desktop/logs/mysql.log  --log-error=/Users/ame/Desktop/logs/mysql.err #--socket=/Users/ame/Desktop/socket -t /Users/ame/Desktop/logs/
#--log-warnings=0
require 'timeout'
module EberTech
  module Snapshot
    class StartDatabaseCommand < Clamp::Command
      def execute
        Database.current.start!
      end          
    end
  end
end
