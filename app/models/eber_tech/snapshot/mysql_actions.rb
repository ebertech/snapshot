module EberTech
  module Snapshot
    module MysqlActions
      class MysqlBaseAction
        attr_accessor :base
      end
      
      class MysqlAdminStop < MysqlBaseAction
        def invoke!
          base.run mysqladmin, [%Q{--defaults-file=#{defaults_file}'}, "shutdown"]                  
        end
      end
      
      class MysqlAdminStart < MysqlBaseAction
        def invoke!
          base.run mysqld_safe, [%Q{--defaults-file=#{defaults_file}'}]    
          begin 
            Timeout::timeout(10) do
              loop do
                run_command(%Q{'#{mysqladmin}' --defaults-file=#{defaults_file}' status})              
                return 0 if $? == 0
              end
            end
          rescue 
            return 1
          end                        
        end
      end      

      class MysqlAdminGrantAccess
        attr_accessor :base, :socket, :mysql, :user

        def initialize(base, mysql, socket, user, config = {})
          self.base = base
          self.socket = socket
          self.mysql = mysql
          self.user = user
        end

        def invoke!      
          base.say_status :mysql, "Granting admin access to current user"
          base.run(mysql, ["-u root", "--defaults-file=#{defaults_file}'", %Q{-e "grant shutdown on *.* to #{user}@localhost"}])
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
          #TODO check for existing, ask for overwrite
          #check for pretend
          base.say_status :mysql, "Creating database"
          base.run(mysql_install_db, ["--datadir='#{database_files_dir}'", "--ldata='#{database_files_dir}'", "--basedir='#{mysql_base_dir}'"])
        end
      end
      
      def create_database
        action MysqlAdminCreateDatabase.new(self, mysql_install_db, database_files_dir, mysql_base_dir, mysql, socket, user)
      end

      def grant_access
        action MysqlAdminGrantAccess.new(self, mysql, socket, user)    
      end      
      
    end
  end
end