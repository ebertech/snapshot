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
            each_tag(configuration) do |tag|
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
          
          private
          
          def overwrite_tag(configuration,tag)

            puts "Saving tag #{tag}"            
            EberTech::Snapshot::Commands::StopDatabaseCommand.execute([])
            puts "here #{__LINE__}"            
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' add .
            })     
            puts "here #{__LINE__}"            

            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' commit -m "#{description}" -a
            })     
                        puts "here #{__LINE__}"            

            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' tag -f "#{tag}"
            })           
                        puts "here #{__LINE__}"            
    
            EberTech::Snapshot::Commands::StartDatabaseCommand.execute([])            
            puts "here #{__LINE__}"            
            
          end
        end
      end
    end
  end
end