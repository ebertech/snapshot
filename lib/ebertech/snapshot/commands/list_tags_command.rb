module EberTech
  module Snapshot
    module Commands
      class ListTagsCommand < ::EberTech::Snapshot::Command
        class << self
          def command_name
            "tags"
          end
          def description
            %Q{List tags in the database}
          end
          def execute(arguments)
            configuration = ::EberTech::Snapshot::Configuration.new          
            each_tag(configuration) do |tag, description|
              puts "#{tag}: #{description}"
            end
            return $? == 0 ? 0 : 1
          end          
        end
      end
    end
  end
end