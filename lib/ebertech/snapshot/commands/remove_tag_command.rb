# #!/bin/bash
# cd db/test_data && git tag -d $1
module EberTech
  module Snapshot
    module Commands
      class RemoveTagCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "remove"
          end
          def description
            %Q{Removes a given tag from the repository}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            tag = ask_for_existing_tag(configuration, arguments)         
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' tag -d #{tag} 
            })     
            return $? == 0 ? 0 : 1
          end
        end
      end
    end
  end
end