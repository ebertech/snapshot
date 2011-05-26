# # #!/bin/bash
# # cd db/test_data && rm -f clean.txt
# 
module EberTech
  module Snapshot
    module Commands
      class MarkDirtyCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "mark_dirty"
          end
          def description
            %Q{Marks the database as needing to be reset}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.new
            if File.exists?(configuration.version_file)
              FileUtils.rm(configuration.version_file)
            end
            return 0
          end
        end
      end
    end
  end
end