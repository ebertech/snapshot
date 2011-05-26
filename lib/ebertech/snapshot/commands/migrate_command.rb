# #!/bin/bash
# cd /usr/local/mysql && sudo bin/mysqladmin shutdown
# 
# # 
module EberTech
  module Snapshot
    module Commands
      class MigrateCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "migrate"
          end
          def description
            %Q{Migrate all tags using the current migrations}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.new          
            each_tag(configuration) do |tag, description|
              puts "Migrating #{tag}"
              puts "Marking directory dirty"
              run_command("snapshot mark_dirty")
              puts "Resetting to tag #{tag}"
              run_command("snapshot reset #{tag}")
              puts "Running rake db:migrate"
              run_command_and_output(%Q{rake db:migrate})
              puts "Saving tag #{tag}"            
              run_command("snapshot save -o #{tag}")
            end               
            return 1
          end
        end
      end
    end
  end
end