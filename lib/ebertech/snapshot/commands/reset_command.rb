# #!/bin/bash
# if /Users/ame/sbin/is_dirty $1; then
# /Users/ame/sbin/stop_mysql > /dev/null 2>&1
# cd /usr/local/mysql/data2 && sudo -u _mysql git clean -d -f > /dev/null 2>&1
# cd /usr/local/mysql && sudo -u _mysql git reset --hard $1 > /dev/null 2>&1
# sudo -u _mysql /Users/ame/sbin/mark_clean $1
# if /Users/ame/sbin/start_mysql > /dev/null 2>&1; then
#     exit 0
# else
#     echo "FAILURE!"
#     exit 1
# fi
# else
#     echo "it's clean!"
# fi
module EberTech
  module Snapshot
    module Commands
      class ResetCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "reset"
          end
          def description
            %Q{Resets the database to a given revision or tag. Starts and stops the db in the process.}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            raise ArgumentError.new("Must specify a revision or tag") unless arguments.size == 1            
            revision = arguments.first
            if is_clean?(revision)
              puts "it's clean!"
              return 0
            else
              EberTech::Snapshot::Commands::StopDatabaseCommand.execute([])
              run_command(%Q{
                cd '#{configuration.data_dir}' && \
                  '#{configuration.git}' clean -d -f
              })     
              run_command(%Q{
                cd '#{configuration.data_dir}' && \
                  '#{configuration.git}' reset --hard #{revision}
              })     
              EberTech::Snapshot::Commands::MarkCleanCommand.execute([revision])
              EberTech::Snapshot::Commands::StartDatabaseCommand.execute([])
            end
            return $? == 0 ? 0 : 1
          end
        end
      end
    end
  end
end