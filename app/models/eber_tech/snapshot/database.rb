module EberTech
  module Snapshot
    class Database
      class << self
        def create!
          generate!(:initialize_snapshot)

          configuration.create_database!
          configuration.create_git_repository!

          configuration = ::EberTech::Snapshot::Configuration.new
          configuration.prepare!

          run_command(configuration.create_database_command)
          run_command(configuration.create_git_repository_command)      
        end
        
        def current
          
        end
      end
      
      def remove_tag!(tag)
        configuration = ::EberTech::Snapshot::Configuration.new
        tag = ask_for_existing_tag(configuration, arguments)         
        run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' tag -d #{tag} 
        })
        
      end
      
      def save_tag!(tag, overwrite = false)
        configuration = ::EberTech::Snapshot::Configuration.new
        non_interactive = false
        tag = nil
        description = nil
        overwrite = false

        if arguments.first == "-o"
          overwrite = true
          arguments.shift
          tag = arguments.shift                          
          description = get_tag_description(configuration, tag)
        else
          tag = ask_for_new_tag(configuration, arguments)
          overwrite = tag_exists?(configuration, tag)              
          description = ask_for_description
        end
        
        EberTech::Snapshot::Commands::StopDatabaseCommand.execute([])
                    
        run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' add .
        })     
        run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' commit -m "#{description}" -a
        })     
        run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' tag #{overwrite ? "-f" : ""} "#{tag}"
        })               
        EberTech::Snapshot::Commands::StartDatabaseCommand.execute([])        
      end
      
      def reset_to!(tag, force = false)
        configuration = ::EberTech::Snapshot::Configuration.new           
         force = false
         revision = arguments.shift
         if revision == "-f"
           force = true
           revision = arguments.shift
         end
         revision ||= ask_for_existing_tag(configuration)     
         
         if force
           EberTech::Snapshot::Commands::MarkDirtyCommand.execute([])              
         end            
         
         if is_clean?(revision)
           puts "it's clean!"
           return 0
         else
           EberTech::Snapshot::Commands::StopDatabaseCommand.execute([])
           run_command(%Q{
             cd '#{configuration.data_dir}' && \
               '#{configuration.git}' clean -d -f
           })     
           run_command(%Q{
             cd '#{configuration.data_dir}' && \
               '#{configuration.git}' reset --hard #{revision}
           })     
           EberTech::Snapshot::Commands::MarkCleanCommand.execute([revision])
           EberTech::Snapshot::Commands::StartDatabaseCommand.execute([])
         end
        
      end
      
      def stop!
        configuration = ::EberTech::Snapshot::Configuration.new
        run_command(%Q{
            '#{configuration.mysql}' -u root \
            --socket='#{configuration.socket}'\
            -e "grant shutdown on *.* to #{ENV["USER"]}@localhost"
        })            
        run_command(%Q{'#{configuration.mysql_admin}' --socket='#{configuration.socket}' shutdown })        
      end

      def tags
        configuration = ::EberTech::Snapshot::Configuration.new          
        Tag.all(configuration).each do |tag|

        end
      end
      
      def mark_clean!
        configuration = ::EberTech::Snapshot::Configuration.new
        raise ArgumentError.new("Must specify revision or tag") unless arguments.size == 1
        if File.exists?(configuration.version_file)
          FileUtils.rm(configuration.version_file)
        end
        File.open(configuration.version_file, "w+") do |f|
          f << arguments.first
        end
        
      end
      
      def pull!
        configuration = ::EberTech::Snapshot::Configuration.new
        unless configuration.repository
          configuration.repository = HighLine.new.ask("Please specify the git repo: ") do |q|
            q.validate = /^ssh:\/\/.+$/
          end     
          puts "Saving configuration for next time"
          configuration.save
        end
        unless remote_origin_exists?(configuration)
          puts "adding origin "
          run_command(%Q{
            cd '#{configuration.data_dir}' && \
              '#{configuration.git}' remote add origin #{configuration.repository}
          })                 
        end
        run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' fetch -f --tags origin master
        })   

        run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' pull -f origin master
        })   
        
      end
      
      def generate!(generator)
        SnapshotGenerator.new.invoke(generator)          
      end      
      def migrate!
        configuration = ::EberTech::Snapshot::Configuration.new          
        each_tag(configuration) do |tag, description|
          puts "Migrating #{tag}"
          puts "Marking directory dirty"
          run_command("snapshot mark_dirty")
          puts "Resetting to tag #{tag}"
          run_command("snapshot reset #{tag}")
          puts "Running rake db:migrate"
          run_command_and_output(%Q{rake db:migrate})
          puts "Saving tag #{tag}"            
          run_command("snapshot save -o #{tag}")
        end
        
      end
      
      def push!
          configuration = ::EberTech::Snapshot::Configuration.new
          unless configuration.repository
            configuration.repository = HighLine.new.ask("Please specify the git repo: ") do |q|
              q.validate = /^ssh:\/\/.+$/
            end     
            puts "Saving configuration for next time"
            configuration.save
          end
          unless remote_origin_exists?(configuration)
            puts "adding origin "
            run_command(%Q{
              cd '#{configuration.data_dir}' && \
                '#{configuration.git}' remote add origin #{configuration.repository}
            })                 
          end
          run_command(%Q{
            cd '#{configuration.data_dir}' && \
              '#{configuration.git}' push -f origin master --tags
          })        
      end
      
      def start!
        configuration = ::EberTech::Snapshot::Configuration.new                   
         skip_networking = true
         port = nil
         if configuration.port
           skip_networking = false
           port = configuration.port
         end
           
         configuration = ::EberTech::Snapshot::Configuration.new
         FileUtils.mkdir_p(File.dirname(configuration.pid_file))
         FileUtils.mkdir_p(File.dirname(configuration.log_file))
         FileUtils.mkdir_p(File.dirname(configuration.socket))
         FileUtils.mkdir_p(File.dirname(configuration.error_log_file))
         run_command_background(%Q{'#{configuration.mysqld_safe}' \
         --datadir='#{configuration.database_files_dir}' \
         #{skip_networking ? "--skip-networking" : "-P #{port}"} \
         --pid-file='#{configuration.pid_file}' \
         --general-log-file='#{configuration.log_file}'  \
         --log-warnings=0 \
         --log-error='#{configuration.error_log_file}' \
         --socket='#{configuration.socket}' >/dev/null 2>&1})
         begin 
           Timeout::timeout(10) do
             loop do
               run_command(%Q{'#{configuration.mysql_admin}' --socket='#{configuration.socket}' status >/dev/null 2>&1})              
               return 0 if $? == 0
             end
           end
         rescue 
           return 1
         end        
      end
      
      def remote_origin_exists?(configuration)
        output, result = run_command(%Q{
          cd '#{configuration.data_dir}' && \
            '#{configuration.git}' remote show origin})  
        result == 0
      end      
      
      def mark_dirty!
        configuration = ::EberTech::Snapshot::Configuration.new
        if File.exists?(configuration.version_file)
          FileUtils.rm(configuration.version_file)
        end        
      end
      
      private
       
       def ask_for_description
         HighLine.new.ask("Please provide a short description: ") do |q|
           q.validate = /^.+$/
         end
       end      
    end
  end
end