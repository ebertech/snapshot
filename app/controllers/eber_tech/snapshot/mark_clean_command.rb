# #!/bin/bash
# echo -n "$1" > /usr/local/mysql/data2/clean.txt
# cd db/test_data && echo -n "$1" > clean.txt
module EberTech
  module Snapshot
    class MarkCleanCommand < AbstractCommand
      def execute
        database.mark_clean!
      end          
    end
  end
end
