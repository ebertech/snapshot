# #!/bin/bash
# echo -n "$1" > /usr/local/mysql/data2/clean.txt
# cd db/test_data && echo -n "$1" > clean.txt
module EberTech
  module Snapshot
    class MarkCleanCommand < Clamp::Command
      def execute
        Database.current.mark_clean!
      end          
    end
  end
end
