# #!/bin/bash
# cd db/test_data && git tag -d $1
module EberTech
  module Snapshot
    class RemoveTagCommand < AbstractCommand
      parameter "[TAG]", "target tag", :default => nil

      def execute
        database.remove_tag!(tag, base_options)
      end          
    end
  end
end
