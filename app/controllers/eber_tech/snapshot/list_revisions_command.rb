module EberTech
  module Snapshot
    class ListRevisionsCommand < AbstractCommand
      def execute          
        table = []
        table << ["Revision (SHA1)", "Description"]
        
        database.each_revision do |sha1, message|
          table << [sha1, message]
        end
        
        shell.print_table table        
      end          
    end
  end
end
