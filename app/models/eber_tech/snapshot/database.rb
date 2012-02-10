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
      
      def mark_clean!
        raise ArgumentError.new("Must specify revision or tag") unless arguments.size == 1
        if File.exists?(configuration.version_file)
          FileUtils.rm(configuration.version_file)
        end
        File.open(configuration.version_file, "w+") do |f|
          f << arguments.first
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
      
      


      def tags
        configuration = ::EberTech::Snapshot::Configuration.new          
        Tag.all(configuration).each do |tag|

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