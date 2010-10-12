# #!/bin/bash
# /Users/ame/sbin/stop_mysql > /dev/null 2>&1
# cd /usr/local/mysql/data2 && sudo -u _mysql git add . > /dev/null 2>&1 && sudo -u _mysql git commit -m "$1" -a > /dev/null 2>&1 && sudo -u _mysql git tag -a "$1" -m "$1"
# /Users/ame/sbin/start_mysql > /dev/null 2>&1
module EberTech
  module Snapshot
    module Commands
      class SaveCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "save"
          end
          def description
            %Q{Saves the database to a given revision or tag. Starts and stops the db in the process.}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            raise ArgumentError.new("Must specify a revision or tag") unless arguments.size == 1            
            revision = arguments.first
            EberTech::Snapshot::Commands::StopDatabaseCommand.execute([])            
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' add .
            })     
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' commit -m "#{revision}" -a
            })     
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' tag -a "#{revision}" -m "#{revision}"   
            })               
            EberTech::Snapshot::Commands::StartDatabaseCommand.execute([])
          end
        end
      end
    end
  end
end