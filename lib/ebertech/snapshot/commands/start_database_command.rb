# #!/bin/bash
# cd /usr/local/mysql && sudo -u _mysql bin/mysqld_safe --datadir=/usr/local/mysql/data2/ &
# 
# for i in `seq 1 100`; do
#  if mysqladmin status >/dev/null 2>&1; then
#      exit 0
#  fi
# done
# exit 1
# # /usr/local/mysql/bin/mysqld_safe --datadir=/Users/ame/Desktop/data -P 3307 --pid-file=$PWD/pidfile --general-log-file=/Users/ame/Desktop/logs/mysql.log  --log-error=/Users/ame/Desktop/logs/mysql.err --socket=/Users/ame/Desktop/socket -t /Users/ame/Desktop/logs/

module EberTech
  module Snapshot
    module Commands
      class StartDatabase < ::EberTech::Snapshot::Command
        def self.command_name
          "start_database"
        end
        def self.execute(arguments)
          configuration = ::EberTech::Snapshot::Configuration
          configuration.load
          FileUtils.mkdir_p(File.dirname(configuration.pid_file))
          FileUtils.mkdir_p(File.dirname(configuration.log_file))
          FileUtils.mkdir_p(File.dirname(configuration.socket))
          FileUtils.mkdir_p(File.dirname(configuration.error_log_file))
          run_command(%Q{#{configuration.mysqld_safe} --datadir='#{configuration.data_dir}' -P '#{configuration.port}' --pid-file='#{configuration.pid_file}' --general-log-file='#{configuration.log_file}'  --log-error='#{configuration.error_log_file}' --socket='#{configuration.socket}' &})
        end
      end
    end
  end
end