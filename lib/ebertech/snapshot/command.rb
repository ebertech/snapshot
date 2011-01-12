module EberTech
  module Snapshot
    class Command      
      class << self
        def inherited(base)
          @subclasses ||= []
          @subclasses << base
        end

        def run_command_background(command)
          require 'daemons'
          Daemons.daemonize          
          system("#{command}")
        end

        def run_command(command)
          result = `#{command} 2>&1`          
          return [result, $?.to_i]
        end

        def ask_for_new_tag(configuration, arguments = [])
          tag = nil
          tag = arguments.first if arguments.size == 1
          tag ||= ask_for_tag
          
          while tag_exists?(configuration, tag) && !ask_overwrite_tag(tag)
            tag = ask_for_tag
          end
          
          tag
        end       
        
        def ask_for_existing_tag(configuration, arguments = [])
          tag = nil
          tag = arguments.first if arguments.size == 1
          tag = ask_for_tag_with_menu(configuration) unless tag && tag_exists?(configuration, tag)
                  
          tag      
        end
                  
        def ask_overwrite_tag(tag)
          HighLine.new.agree("The tag #{tag} already exists, overwrite? ")
        end        
        
        def tag_exists?(configuration, tag)
          output, result = run_command(%Q{
            cd '#{configuration.data_dir}' && \
            '#{configuration.git}' show refs/tags/#{tag}})
            result == 0
          end        
        
        def ask_for_tag
          HighLine.new.ask("Specify a tag name: ") do |q|
            q.validate = /^.+$/
          end          
        end 
        
        def ask_for_tag_with_menu(configuration)
          HighLine.new.choose do |menu|
            menu.prompt = "Specify a tag name: "
            each_tag(configuration) do |tag|
              menu.choice tag
            end
          end
        end

        def each_tag(configuration)
          output, result = run_command!("cd #{configuration.data_dir} && #{configuration.git} tag -l")
          output.split("\n").sort.each do |tag|
            yield tag.strip
          end          
        end

        def run_command!(command)
          result = `#{command} 2>&1`  
          raise "Failed #{command}" unless $? == 0        
          return [result, $?]
        end        
        
        def confirm_overwrite_if_exists(path, arguments = [])
          raise "No block given" unless block_given?
          asker = HighLine.new    

          if File.exists?(path)
            if arguments.first == "-f" || asker.agree("#{path} exists, overwrite?: ")
              puts "Overwriting #{path}"
              yield 
            else                
              puts "File #{path} exists, force overwrite with -f"
            end
          else
            yield
          end        
        end
        
        def run_command_and_output(command)
          puts run_command(command).first
        end
        
        def configuration_path
          @configuration_path ||= File.join("config", "snapshot.yml")
        end
        
        def database_yml_path
          @database_yml_path ||= File.join("config", "database.yml")          
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