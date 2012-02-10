# # #!/bin/bash
# # cd db/test_data && rm -f clean.txt
module EberTech
  module Snapshot
    class MarkDirtyCommand < AbstractCommand
      def execute
        database.mark_dirty!
      end          
    end
  end
end
