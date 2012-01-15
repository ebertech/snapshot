# # #!/bin/bash
# # cd db/test_data && rm -f clean.txt
module EberTech
  module Snapshot
    class MarkDirtyCommand < Clamp::Command
      def execute
        Database.current.mark_dirty!
      end          
    end
  end
end
