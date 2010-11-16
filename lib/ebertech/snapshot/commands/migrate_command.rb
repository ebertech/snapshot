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
            configuration = ::EberTech::Snapshot::Configuration.load          
            result, status = run_command("cd #{configuration.data_dir} && #{configuration.git} tag")     
            return 0 if status != 0
            result.each_line do |line|
              tag = line.strip
              puts "Migrating #{tag}"
              run_command("snapshot mark_dirty")
              run_command("snapshot reset #{tag}")
              run_command(%Q{rake db:migrate})
              run_command("snapshot remove_tag #{tag}")              
              run_command("snapshot save #{tag}")              
            end               
            return 1
          end
        end
      end
    end
  end
end