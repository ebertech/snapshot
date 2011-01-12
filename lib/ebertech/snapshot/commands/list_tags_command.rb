module EberTech
  module Snapshot
    module Commands
      class ListTagsCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "tags"
          end
          def description
            %Q{List tags in the database}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load          
            run_command_and_output("cd #{configuration.data_dir} && #{configuration.git} tag -l")          
            return $? == 0 ? 0 : 1
          end          
        end
      end
    end
  end
end