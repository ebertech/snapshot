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
    module Commands
      class StartDatabaseCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "start_database"
          end
          def description
            %Q{Start the database}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            FileUtils.mkdir_p(File.dirname(configuration.pid_file))
            FileUtils.mkdir_p(File.dirname(configuration.log_file))
            FileUtils.mkdir_p(File.dirname(configuration.socket))
            FileUtils.mkdir_p(File.dirname(configuration.error_log_file))

            run_command_background(%Q{'#{configuration.mysqld_safe}' \
            --datadir='#{configuration.database_files_dir}' \
            --skip-networking \
            --pid-file='#{configuration.pid_file}' \
            --general-log-file='#{configuration.log_file}'  \
            --log-warnings=0 \
            --log-error='#{configuration.error_log_file}' \
            --socket='#{configuration.socket}' >/dev/null 2>&1
            })
            begin 
              Timeout::timeout(3) do
                loop do
                  run_command(%Q{'#{configuration.mysql_admin}' --socket='#{configuration.socket}' status >/dev/null 2>&1})              
                  return 0 if $? == 0
                end
              end
            rescue 
              return 1
            end
          end
        end
      end
    end
  end
end