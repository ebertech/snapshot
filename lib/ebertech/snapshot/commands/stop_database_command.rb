# #!/bin/bash
# cd /usr/local/mysql && sudo bin/mysqladmin shutdown
# 
# # 
module EberTech
  module Snapshot
    module Commands
      class StopDatabaseCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "stop"
          end
          def description
            %Q{Stop the database}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            run_command(%Q{
                '#{configuration.mysql}' -u root \
                --socket='#{configuration.socket}'\
                -e "grant shutdown on *.* to #{ENV["USER"]}@localhost"
            })            
            run_command(%Q{'#{configuration.mysql_admin}' --socket='#{configuration.socket}' shutdown })              
            return 0 if $? == 0
            return 1
          end
        end
      end
    end
  end
end