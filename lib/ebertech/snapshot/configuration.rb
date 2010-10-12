require 'yaml'
module EberTech
  module Snapshot
    class Configuration      
      class << self
        def configuration_path
          @configuration_path ||= File.join("config", "snapshot.yml")
        end

        def load
          raise "no such file #{configuration_path}. Run snapshot create_config to create." unless File.exists?(configuration_path)
          @configuration = YAML.load(File.read(configuration_path))          
          self
        end
        
        def data_dir
          File.join(Dir.getwd, @configuration["datadir"])
        end
        
        def pid_file
          File.join(Dir.getwd, "tmp", "snapshot.pid")          
        end
        
        def log_file
          File.join(Dir.getwd, "log", "snapshot_log")          
        end
        
        def error_log_file
          File.join(Dir.getwd, "log", "snapshot_error_log")
        end
        
        def socket
          File.join(Dir.getwd, "tmp", "snapshot_socket")
        end
        
        def port
          @configuration["port"]
        end
        
        def git
          @configuration["git"]
        end
        
        def mysql
          @configuration["mysql"]
        end
        
        def mysql_install_db
          @configuration["mysql_install_db"]
        end
        
        def mysql_admin
          @configuration["mysql_admin"]
        end
        
        def mysqld_safe
          @configuration["mysqld_safe"]
        end      
        
        def version_file
          File.join(data_dir, "clean.txt")
        end  
      end
    end
  end
end