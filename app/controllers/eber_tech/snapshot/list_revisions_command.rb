module EberTech
  module Snapshot
    class ListRevisionsCommand < AbstractCommand
      def execute
        database.each_revision do |sha1, message|
          puts "#{sha1}\t\t#{message}"          
        end        
      end          
    end
  end
end
