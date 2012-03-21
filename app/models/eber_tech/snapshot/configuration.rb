module EberTech
  module Snapshot
    class Configuration
      class << self
        def load(*args)
          new(*args) rescue nil
        end
        
        def default_configuration_path
          File.join(snapshot_config_dir, "snapshot.yml") 
        end
        
        def snapshot_config_dir
          File.expand_path ".snapshot"
        end
      end                           
               
      def initialize(path_to_config = nil)
        self.configuration_path =  path_to_config || self.class.default_configuration_path
        self.snapshot_config_dir = File.dirname(configuration_path)    
        raise "no such file #{configuration_path}. Run snapshot create_config to create." unless File.exists?(configuration_path)
        @configuration = YAML.load(File.read(configuration_path)).with_indifferent_access      
        ENV["RAILS_ENV"] = environment_name
      end
      
      attr_accessor :snapshot_config_dir, :configuration_path
      
      def database_configuration
        YAML.load(File.read(database_yml_path)).with_indifferent_access[environment_name]
      end
      
      def database_name
        database_configuration[:database]
      end
      
      def database
        Database.new(self)
      end
      
      def git
        Git.open(data_dir)
      end
      
      def user
        #TODO
        ENV["USER"]
      end

      def data_dir
        File.join(snapshot_config_dir, datadir)
      end
      
      def database_yml_path
        File.join(snapshot_config_dir, "database.yml") 
      end      

      def database_files_dir
        File.join(snapshot_config_dir, @configuration[:database_files_dir])
      end

      def pid_file
        File.join(snapshot_config_dir, "tmp", "snapshot.pid")          
      end

      def log_file
        File.join(snapshot_config_dir, "log", "snapshot.log")          
      end

      def error_log_file
        File.join(snapshot_config_dir, "log", "snapshot_error.log")
      end

      def database_exists?
        File.exists?(configuration_path)
      end

      def socket
        File.join(snapshot_config_dir, "tmp", "sockets", "snapshot_socket")
      end
      
      def mysql_defaults_path
        File.join(snapshot_config_dir, "my.cnf")
      end      

      def repository=(repository)
        @configuration["repository"] = repository
      end
      
      #TODO      
      def mysql_base_dir
        File.expand_path(File.join(%x{which my_print_defaults}.strip, "../.."))
      end
      
      #TODO 
      def mysqldump
        "/usr/local/bin/mysqldump"
      end
      
      CONFIGURATION_FILE_OPTIONS = [:mysql_install_db, :mysqld_safe, :mysql, :database_files_dir, :datadir, :mysqladmin, :environment_name, :port]
      
      def method_missing(method, *args)
        if CONFIGURATION_FILE_OPTIONS.include?(method)
          @configuration[method]
        else
          super
        end
      end

      def version_file
        File.join(data_dir, "clean.txt")
      end  
    end
  end
end