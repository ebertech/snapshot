module EberTech
  module Snapshot
    module GitActions
      class GitRepository
        attr_accessor :base, :data_dir

        def initialize(base, data_dir)
          self.base = base
          self.data_dir = data_dir
        end

        def invoke!
          # ask for overwrite if existing
          base.say_status :git, data_dir, :green
          return if base.pretend?
          Git.init(data_dir).tap do |g|
            g.add(data_dir)
            g.commit("initial commit") 
          end
        end
      end

      def create_git_repository
        action GitRepository.new(self, data_dir)    
      end
    end
  end
end