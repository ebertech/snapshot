module Ebertech
  module Snapshot
    module Commands
      class CreateConfigCommand < ::EberTech::Snapshot::Command
        class << self
          DEFAULT_CONFIG = {
            "datadir" => "db/test_data",
            "database_files_dir" => "db/test_data/database_files",
            "git" => "/usr/local/bin/git",
            "mysql" => "/usr/local/mysql/bin/mysql",
            "mysqld_safe" => "/usr/local/mysql/bin/mysqld_safe",
            "mysql_admin" => "/usr/local/mysql/bin/mysqladmin",
            "mysql_install_db" => "/usr/local/mysql/bin/mysql_install_db"
          }
          DEFAULT_DATABASE = {
            "adapter" => "mysql"
          }
          
          def command_name
            "config"
          end

          def description
            %Q{Creates an empty config file and a database.yml}
          end
          def execute(arguments)
            ensure_config_dir!
            create_snapshot_yml!(arguments)
            create_database_yml!(arguments)
            return 0
          end
          private
          
          def ask_database_name
            HighLine.new.ask("Database name: ") do |question|
              if File.exists?("Ebermin")
                question.default = YAML.load(File.read("Ebermin"))["project"]
              end
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
          
          def create_database_yml!(arguments)
            configuration = ::EberTech::Snapshot::Configuration.load
            confirm_overwrite_if_exists(database_yml_path, arguments) do              
              environment_name =  ask_environment_name  

              settings = DEFAULT_DATABASE.dup
              settings["socket"] = configuration.socket         
              settings["database"] = ask_database_name  
              settings["username"] = ask_database_username  
              
              File.open(database_yml_path, "w+").write({environment_name => settings}.to_yaml)        
            end               
          end
          
          def create_snapshot_yml!(arguments)
            confirm_overwrite_if_exists(configuration_path, arguments) do
              File.open(configuration_path, "w+").write(DEFAULT_CONFIG.to_yaml)        
            end              
          end
          
          def ensure_config_dir!
            FileUtils.mkdir_p("config")            
          end
        end
      end
    end
  end
end