module EberTech
  module Snapshot
    module RakeActions

      def rake_task(name)
            say_status :snapshot,  "Running rake db:migrate", :green        
        Rake.application.init
        Rake.application.load_rakefile
        Rake::Task["db:migrate"].invoke
      end
    end
  end
end