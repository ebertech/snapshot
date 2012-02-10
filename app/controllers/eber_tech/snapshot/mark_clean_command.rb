# #!/bin/bash
# echo -n "$1" > /usr/local/mysql/data2/clean.txt
# cd db/test_data && echo -n "$1" > clean.txt
module EberTech
  module Snapshot
    class MarkCleanCommand < AbstractCommand
      parameter "TAG", "target tag", :default => nil      
      
      def execute
        database.mark_clean!(tag, base_options)
      end          
    end
  end
end
