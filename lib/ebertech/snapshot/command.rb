module EberTech
  module Snapshot
    class Command      
      class << self
        def inherited(base)
          @subclasses ||= []
          @subclasses << base
        end
        
        def run_command_backrgound(command)
          fork do
            system("#{command}")
          end
        end
        
        def run_command(command)
          result = `#{command} 2>&1`          
          return [result, $?]
        end
        
        def run_command_and_output(command)
          puts run_command(command).first
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
          if File.exists?(configuration.version_file)
            File.read(configuration.version_file).strip == revision.to_s
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
            exit command.execute(arguments)
          end            
        end

        def show_usage
          puts %Q{Usage: #{$0} COMMAND}
          puts %Q{Where command is any of the following:}
          @subclasses.each do |command|
            puts sprintf("\t%-20s%s", command.command_name, command.description)
          end
          return true
        end
      end
    end
  end
end