# #!/bin/bash
# cd db/test_data && git tag -d $1
module EberTech
  module Snapshot
    module Commands
      class RemoveTagCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "remove_tag"
          end
          def description
            %Q{Removes a given tag from the repository}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            raise ArgumentError.new("Must specify tag") unless arguments.size == 1            
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' tag -d #{arguments.first} 
            })     
            return $? == 0 ? 0 : 1
          end
        end
      end
    end
  end
end