module EberTech
  module Snapshot
    class ListTagsCommand < AbstractCommand
      def execute
        database.each_tag do |tag, message|
          puts "#{tag}\t\t#{message}"          
        end
      end          
    end
  end
end
