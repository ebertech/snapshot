# #!/bin/bash
# /Users/ame/sbin/stop_mysql > /dev/null 2>&1
# cd /usr/local/mysql/data2 && sudo -u _mysql git add . > /dev/null 2>&1 && sudo -u _mysql git commit -m "$1" -a > /dev/null 2>&1 && sudo -u _mysql git tag -a "$1" -m "$1"
# /Users/ame/sbin/start_mysql > /dev/null 2>&1
module EberTech
  module Snapshot
    class SaveCommand < AbstractCommand
      parameter "TAG", "target tag", :default => nil
      
      def execute
        database.save_tag!(tag, force?)
      end       
    end
  end
end
