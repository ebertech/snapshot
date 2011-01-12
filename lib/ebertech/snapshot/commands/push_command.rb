module EberTech
  module Snapshot
    module Commands
      class PushCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "push"
          end
          def description
            %Q{Push to a remote repository}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            unless configuration.repository
              configuration.repository = HighLine.new.ask("Please specify the git repo: ") do |q|
                q.validate = /^ssh:\/\/.+$/
              end     
              puts "Saving configuration for next time"
              configuration.save
            end
            unless remote_origin_exists?(configuration)
              puts "adding origin "
              run_command(%Q{
                cd '#{configuration.data_dir}' && \
                  '#{configuration.git}' remote add origin #{configuration.repository}
              })                 
            end
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' push -f origin master
            })   
            
            return 0
          end
          
          private
          
          def remote_origin_exists?(configuration)
            output, result = run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' remote show origin})  
            result == 0
          end
        end
      end
    end
  end
end