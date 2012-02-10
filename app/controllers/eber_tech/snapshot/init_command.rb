module EberTech
  module Snapshot
    class InitCommand < AbstractCommand     
      include EberTech::CommandLine::Actions
      
      def execute   
        options = {:pretend => dry_run?}  
        options[:environment_name] =  ask_environment_name  
        options[:database] = ask_database_name  
        options[:username] = ask_database_username      
        options[:port] = ask_port
                
        [
          :mysql_install_db, 
          :mysqld_safe,
          :mysql, 
          :git,
          :mysqladmin
        ].each do |command|
          options[command] = which(command.to_s) || raise("Can't find #{command} in path")
        end
                
        EberTech::Snapshot::Generator.new([], options).invoke(:initialize_snapshot)        
      end
      
      private
      
      def ask_database_name
        HighLine.new.ask("Database name: ") do |question|
          if File.exists?("Ebermin")
            question.default = YAML.load(File.read("Ebermin"))["project"]
          end
        end
      end

      def ask_port
        HighLine.new.ask("Port to listen on (leave blank to disable): ") do |question|
          question.default = ""
        end    
      end

      def ask_environment_name
        HighLine.new.ask("Environment: ") do |question|
          question.default = "development"
        end
      end

      def ask_database_username
        HighLine.new.ask("Username: ") do |question|
          question.default = "root"
        end
      end      
    end
  end
end