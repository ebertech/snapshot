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
          ".snapshot"
        end
      end                           
               
      def initialize(configuration_path = nil)
        configuration_path ||=  self.class.default_configuration_path  
        self.snapshot_config_dir = File.dirname(configuration_path)    
        raise "no such file #{configuration_path}. Run snapshot create_config to create." unless File.exists?(configuration_path)
        @configuration = YAML.load(File.read(configuration_path)).with_indifferent_access      
        @working_dir = File.expand_path("../..", configuration_path)
        ENV["RAILS_ENV"] = environment_name
      end
      
      attr_accessor :snapshot_config_dir
      
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
        File.join(@working_dir, datadir)
      end

      def database_files_dir
        File.join(@working_dir, @configuration[:database_files_dir])
      end

      def pid_file
        File.join(@working_dir, "tmp", "snapshot.pid")          
      end

      def log_file
        File.join(@working_dir, "log", "snapshot.log")          
      end

      def error_log_file
        File.join(@working_dir, "log", "snapshot_error.log")
      end

      def database_exists?
        File.exists?(File.join(database_files_dir,"mysql/db.MYD"))
      end

      def socket
        File.join(@working_dir, "tmp", "sockets", "snapshot_socket")
      end
      
      def mysql_defaults_path
        File.join(snapshot_config_dir, "my.cnf")
      end      

      def repository=(repository)
        @configuration["repository"] = repository
      end
      
      #TODO      
      def mysql_base_dir
        "/usr/local/Cellar/mysql/5.5.19"
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