module EberTech
  module Snapshot
    class ListTagsCommand < AbstractCommand
      def execute
        table = []
        table << ["Tag", "Description"]
        
        database.each_tag do |tag, message|
          table << [tag, message]
        end
        
        Thor::Shell::Color.new.print_table table
      end          
    end
  end
end
