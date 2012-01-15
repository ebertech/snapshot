module EberTech
  module Snapshot
    class ListTagsCommand < Clamp::Command
      def execute
        Database.current.tags.each do |tag|
          puts "#{tag.name}: #{tag.description}"          
        end
      end          
    end
  end
end
