# #!/bin/bash
# echo -n "$1" > /usr/local/mysql/data2/clean.txt
# cd db/test_data && echo -n "$1" > clean.txt

module EberTech
  module Snapshot
    module Commands
      class MarkCleanCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "mark_clean"
          end
          def description
            %Q{Marks the database as at a given state}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.new
            raise ArgumentError.new("Must specify revision or tag") unless arguments.size == 1
            if File.exists?(configuration.version_file)
              FileUtils.rm(configuration.version_file)
            end
            File.open(configuration.version_file, "w+") do |f|
              f << arguments.first
            end
            return 0
          end
        end
      end
    end
  end
end