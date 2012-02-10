module EberTech
  module Snapshot
    class PushCommand < AbstractCommand
      def execute
        database.push!(base_options)      
      end   
    end
  end
end
