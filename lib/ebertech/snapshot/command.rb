module EberTech
  module Snapshot
    class Command      
      class << self
        def inherited(base)
          @subclasses ||= []
          @subclasses << base
        end
        def run_command(command)
          result = `#{command}`          
        end
        def configuration_path
          @configuration_path ||= File.join("config", "snapshot.yml")
        end
        def load_commands
          @commands ||= {}
          @subclasses.each do |subclass|
            raise "#{subclass.name} must implement command_name" unless subclass.respond_to?(:command_name)
            @commands[subclass.command_name] = subclass
          end
        end

        def is_clean?(revision)
          configuration = Configuration.load
          if File.exists?(configuration.version_file_path)
            File.read(configuration.version_file_path) == revision
          else
            false
          end
        end

        def execute(arguments)
          if arguments.empty?
            puts "No arguments"
            show_usage and exit(1)
          end
          command_name = arguments.shift
          command = @commands[command_name]
          unless command
            puts "No such command #{command_name}"
            show_usage and exit(1)            
          else
            command.execute(arguments)
          end            
        end

        def show_usage
          puts "Hi, this is a usage message."
          return true
        end
      end
    end
  end
end