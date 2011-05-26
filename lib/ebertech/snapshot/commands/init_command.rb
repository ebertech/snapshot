module EberTech
  module Snapshot
    module Commands
      class InitCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "init"
          end
        
          def description
            %Q{Creates the data_dir, initializes the database and setups up a git repository and commits the state of the newly created database to it.}
          end
        
          def execute(arguments)
            SnapshotGenerator.new.invoke(:initialize_snapshot)
            
            configuration = ::EberTech::Snapshot::Configuration.new
            
            FileUtils.mkdir_p(configuration.database_files_dir)
            
            run_command(%Q{
              '#{configuration.mysql_install_db}' \
                --datadir='#{configuration.database_files_dir}'  \
                --ldata='#{configuration.database_files_dir}'
            })
            
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' init && \
                '#{configuration.git}' add . && \
                '#{configuration.git}' commit -m 'initial commit'
            })      
            return 0    
          end
        end
      end
    end
  end
end