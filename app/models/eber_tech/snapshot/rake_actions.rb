module EberTech
  module Snapshot
    module RakeActions
      def rake_task(name)
        say_status :rake,  name, :green        
        # Rake.application.init
        # Rake.application.load_rakefile
        # Rake::Task[name].invoke
        run("rake #{name}")
      end
    end
  end
end