# #!/bin/bash
# if /Users/ame/sbin/is_dirty $1; then
# /Users/ame/sbin/stop_mysql > /dev/null 2>&1
# cd /usr/local/mysql/data2 && sudo -u _mysql git clean -d -f > /dev/null 2>&1
# cd /usr/local/mysql && sudo -u _mysql git reset --hard $1 > /dev/null 2>&1
# sudo -u _mysql /Users/ame/sbin/mark_clean $1
# if /Users/ame/sbin/start_mysql > /dev/null 2>&1; then
#     exit 0
# else
#     echo "FAILURE!"
#     exit 1
# fi
# else
#     echo "it's clean!"
# fi
module EberTech
  module Snapshot
    class ResetCommand < AbstractCommand
      parameter "[TAG]", "target tag", :default => nil

      def execute
        database.reset_to!(tag, base_options)
      end          
    end
  end
end
