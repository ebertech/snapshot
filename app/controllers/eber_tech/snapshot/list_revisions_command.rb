module EberTech
  module Snapshot
    class ListRevisionsCommand < Clamp::Command
      def execute
        Database.current.revisions.each do |revision|
          puts "#{revision.name}: #{revision.description}"          
        end        
      end          
    end
  end
end
