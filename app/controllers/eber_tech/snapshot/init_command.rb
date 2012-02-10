module EberTech
  module Snapshot
    class InitCommand < AbstractCommand           
      def execute   
        EberTech::Snapshot::Generator.new([], base_options).invoke(:initialize_snapshot)        
      end  
    end
  end
end