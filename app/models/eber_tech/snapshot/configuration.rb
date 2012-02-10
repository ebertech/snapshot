require 'yaml'
module EberTech
  module Snapshot
    class Configuration         
      def initialize(configuration_path = File.join("config", "snapshot.yml"))
        raise "no such file #{configuration_path}. Run snapshot create_config to create." unless File.exists?(configuration_path)
        @configuration = YAML.load(File.read(configuration_path))          
        @working_dir = File.expand_path("../..", configuration_path)
      end
      
      def database
        Database.new(self)
      end
      
      def git
        Git.open(data_dir)
      end

      def data_dir
        File.join(@working_dir, @configuration["datadir"])
      end

      def database_files_dir
        File.join(@working_dir, @configuration["database_files_dir"])
      end

      def pid_file
        File.join(@working_dir, "tmp", "snapshot.pid")          
      end

      def log_file
        File.join(@working_dir, "log", "snapshot_log")          
      end

      def error_log_file
        File.join(@working_dir, "log", "snapshot_error_log")
      end

      def socket
        File.join(@working_dir, "tmp", "sockets", "snapshot_socket")
      end

      def port
        @configuration["port"]
      end

      def repository
        @configuration["repository"]
      end

      def repository=(repository)
        @configuration["repository"] = repository
      end

      def mysql
        @configuration["mysql"]
      end

      def mysql_install_db
        @configuration["mysql_install_db"]
      end
      
      def mysql_base_dir
        "/usr/local/Cellar/mysql/5.5.19"
      end

      def mysqladmin
        @configuration["mysqladmin"]
      end

      def mysqld_safe
        @configuration["mysqld_safe"]
      end      

      def version_file
        File.join(data_dir, "clean.txt")
      end  
      
      def configuration_path
        @configuration_path ||= File.join("config", "snapshot.yml")
      end
      
      def database_yml_path
        @database_yml_path ||= File.join("config", "database.yml")          
      end
    end
  end
end