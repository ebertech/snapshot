module EberTech
  module Snapshot
    class ListTagsCommand < AbstractCommand
      def execute
        table = []
        table << [shell.set_color("Tag", :white), "Description"]
        
        database.each_tag do |tag, message|
          table << [shell.set_color(tag, :green), message]
        end
        
        shell.print_table table
      end          
    end
  end
end
