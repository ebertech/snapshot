module EberTech
  module Snapshot
    class Database
      attr_accessor :configuration
      
      def initialize(configuration)
        self.configuration = configuration
      end
      
      def each_revision
        configuration.git.log.each{|l| yield l.sha,l.message }
      end
      
      def each_tag
        configuration.git.tags.each do |tag|          
          yield tag.name, configuration.git.gcommit(tag.objectish).message
        end
      end
      
      def mark_clean!(tag)
        File.open(configuration.version_file, "w+") do |f|
          f << tag
        end        
      end      
      
      def mark_dirty!
        if File.exists?(configuration.version_file)
          FileUtils.rm(configuration.version_file)
        end        
      end      
      
      def migrate!       
        each_tag do |tag, description|
          puts "Migrating #{tag}"
          puts "Marking directory dirty"
          mark_dirty!
          puts "Resetting to tag #{tag}"
          reset_to!(tag)
          puts "Running rake db:migrate"
          run_command_and_output(%Q{rake db:migrate})
          puts "Saving tag #{tag}"            
          save(tag)
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
      
       def start!
           skip_networking = true
           port = nil
           if configuration.port
             skip_networking = false
             port = configuration.port
           end

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
    

      
      def pull!
        raise "TODO"
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

         def get_tag_description(configuration, tag)
           output, result = run_command!(%Q{
             cd '#{configuration.data_dir}' && \
             '#{configuration.git}' show  -s --format=%s refs/tags/#{tag}})
           output.strip
         end

         def ask_for_tag_with_menu(configuration)
           HighLine.new.choose do |menu|
             menu.prompt = "Specify a tag name: "
             each_tag(configuration) do |tag, description|
               menu.choice tag
             end
           end
         end

         def get_tag_revision(configuration, tag)
           output, result = run_command!("cd #{configuration.data_dir} && #{configuration.git} rev-parse #{tag}")          
           output.strip
         end        

         def each_tag(configuration)
           output, result = run_command!("cd #{configuration.data_dir} && #{configuration.git} tag -l")
           output.split("\n").sort.each do |tag|
             description = get_tag_description(configuration, tag)                        
             yield tag.strip, description
           end          
         end

         def is_clean?(revision)
           configuration = Configuration.new
           if File.exists?(configuration.version_file)
             File.read(configuration.version_file).strip == revision.to_s
           else
             false
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
     
      def push!
        raise "TODO"
        
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
          
      private
       
       def ask_for_description
         HighLine.new.ask("Please provide a short description: ") do |q|
           q.validate = /^.+$/
         end
       end      
    end
  end
end