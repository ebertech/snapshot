module EberTech
  module Snapshot
    module MysqlActions
      class MysqlBaseAction
        attr_accessor :base
        def initialize(base, *args)
          self.base = base
        end        
      end
      
      class MysqlAdminStop < MysqlBaseAction     
        attr_accessor :mysqladmin, :defaults_file
        
        def initialize(base, mysqladmin, defaults_file, config = {})
          super
          self.mysqladmin = mysqladmin
          self.defaults_file = defaults_file
        end        
           
        def invoke!
          base.run mysqladmin, [%Q{--defaults-file='#{File.expand_path(defaults_file)}'}, "shutdown"]                  
        end
      end
      
      class MysqlAdminStart < MysqlBaseAction
        attr_accessor :mysqld_safe, :mysqladmin, :defaults_file, :port, :config
        
        def initialize(base, mysqld_safe, mysqladmin, defaults_file, port, config = {})
          super
          self.mysqld_safe = mysqld_safe
          self.mysqladmin = mysqladmin
          self.defaults_file = defaults_file
          self.port = port
          self.config = config
        end        
        
        def invoke!
          args = [%Q{--defaults-file='#{File.expand_path(defaults_file)}'}]
          base.shell.say_status :mysql, "Starting database", :green
          return if base.pretend?
          base.run_in_background mysqld_safe, args, config    
          
          wait_until(10) do
            base.shell.mute do 
              base.run mysqladmin, [%Q{--defaults-file='#{defaults_file}'}, "status"]
            end
          end                
        end
        
        def wait_until(timeout)
          begin
            Timeout::timeout(30) do
              loop do
                yield    
                return if $? == 0
                sleep 1
              end
            end            
          rescue
            puts $!
            base.say_status :mysql, "Failed to start, aborting", :red
            exit 1
          end
        end
      end      

      class MysqlAdminGrantAccess
        attr_accessor :base, :mysql, :defaults_file, :user

        def initialize(base, mysql, defaults_file, user, config = {})
          self.base = base
          self.mysql = mysql
          self.defaults_file = defaults_file
          self.user = user
        end

        def invoke!      
          base.say_status :mysql, "Granting admin access to current user"
          base.run(mysql, ["--defaults-file='#{defaults_file}'", "-u root", %Q{-e "grant shutdown on *.* to #{user}@localhost"}])
        end    
      end

      class MysqlAdminCreateDatabase
        attr_accessor :base, :mysql_install_db, :database_files_dir, :mysql_base_dir

        def initialize(base, mysql_install_db, database_files_dir, mysql_base_dir, config = {})
          self.base = base
          self.mysql_install_db = mysql_install_db
          self.database_files_dir = database_files_dir       
          self.mysql_base_dir = mysql_base_dir   
        end

        def invoke!                
          base.say_status :mysql, "Creating database"
          base.run(mysql_install_db, ["--datadir='#{database_files_dir}'", "--ldata='#{database_files_dir}'", "--basedir='#{mysql_base_dir}'"])
        end
      end
      
      def create_database!(mysql_install_db, database_files_dir, mysql_base_dir, options = {})
        action MysqlAdminCreateDatabase.new(self, mysql_install_db, database_files_dir, mysql_base_dir)
      end

      def grant_access!(mysql, defaults_file, user, options = {})
        action MysqlAdminGrantAccess.new(self, mysql, defaults_file, user)    
      end      
      
      def stop_database!(mysqladmin, defaults_file, options = {})
        action MysqlAdminStop.new(self, mysqladmin, defaults_file, options)
      end

      def start_database!(mysqld_safe, mysqladmin, defaults_file, port, options = {})
        action MysqlAdminStart.new(self, mysqld_safe, mysqladmin, defaults_file, port, options)
      end
    end
  end
end