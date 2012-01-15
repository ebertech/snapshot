# #!/bin/bash
# cd db/test_data && git tag -d $1
module EberTech
  module Snapshot
    class RemoveTagCommand < Clamp::Command
      def execute
        Database.current.remove_tag!(tag)
      end          
    end
  end
end
