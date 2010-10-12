module EberTech
  module Snapshot
    module Commands
      class ListRevisionsCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "list"
          end
          def description
            %Q{List revisions in the database}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load          
            run_command_and_output("cd #{configuration.data_dir} && #{configuration.git} log")          
            return $? == 0 ? 0 : 1
          end          
        end
      end
    end
  end
end