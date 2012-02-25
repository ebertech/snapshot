module EberTech
  module Snapshot
    class Database < Thor::Group
      include Thor::Actions
      include EberTech::CommandLine::Actions        
      include MysqlActions
      include RakeActions

      attr_accessor :configuration

      def initialize(configuration)
        self.configuration = configuration
      end

      def each_revision
        git.log.each{|l| yield l.sha,l.message }
      end

      def each_tag
        git.tags.each do |tag|          
          yield tag.name, git.gcommit(tag.objectish).message
        end
      end
      
      def each_tag_with_revision
        git.tags.each do |tag|          
          yield tag.name, git.gcommit(tag.objectish).message, tag.objectish
        end        
      end

      def mark_clean!(tag, options = {})
        File.open(version_file, "w+") do |f|
          f.write tag
        end        
      end      

      def mark_dirty!(options = {})
        say_status :snapshot,  "Marking directory dirty", :green        
        if File.exists?(version_file)
          FileUtils.rm(version_file)
        end        
      end      

      def migrate!(options = {})    
        each_tag do |tag, description|
          say_status :snapshot, "Migrating #{tag}", :green
          with_stopped_database(options) do                
            mark_dirty!
            reset_to!(tag)
            rake_task("db:migrate")
            save_tag!(tag, nil, :force => true)
          end
        end
      end

      def stop!(options = {})
        if is_running?
          stop_database! mysqladmin, mysql_defaults_path, options
        end
        if is_running?
          force_quit!(options)
        end
        print_status(options)
      end
      
      def force_quit!(options = {})
        say_status :kill, "Forcefully killing database"
        Process.kill(9, get_process_id) rescue nil
      end

      def create!(options = {})
        create_database! mysql_install_db, database_files_dir, mysql_base_dir, options      
      end
      
      def grant!(options = {})
        grant_access! mysql, mysql_defaults_path, user, options
      end
      
      def print_status(options = {})
        if is_running?
          say_status :snapshot, "Database is running at #{get_process_id}", :green
          true
        else
          say_status :snapshot, "Database is not running", :red
          false
        end        
      end

      def start!(options = {})
        unless is_running?
          start_database! mysqld_safe, mysqladmin, mysql_defaults_path, port, options
        end
        print_status(options)
      end

      def pull!(options = {})
        create_remote_origin!(options)

        #fetch -f --tags origin master
        git.fetch("origin")

        #pull -f origin master
        git.pull("origin", "master")
      end

      def push!(options = {})
        create_remote_origin!(options)
        git.push("origin", "master", true)  
      end
      
      def pretend?
        false
      end

      def save_tag!(tag, description, options = {})
        tag = ask_for_new_tag(tag, options)
        if tag_exists?(tag)
          description ||= get_tag_description(tag)
          remove_tag!(tag)
        end
        
        description ||= ask_for_description(tag)
        say_status :snapshot,  "Saving tag #{tag}", :green        
        with_stopped_database(options) do
          git.add(".")
          git.commit(description)
          git.add_tag(tag)
        end
      end

      def remove_tag!(tag, options = {})
        tag = ask_for_existing_tag(tag)
        say_status :snapshot,  "Removing tag #{tag}", :red 
        git.remove_tag(tag)        
      end

      def is_running?        
        return false unless get_process_id
        !!Process.getpgid(get_process_id) rescue false
      end
      
      def get_process_id
        return false unless File.exists?(pid_file)
        File.read(pid_file).lines.first.strip.to_i
      end

      def reset_to!(revision, options = {})
        force = options[:force]       
        revision ||= ask_for_existing_tag(revision)     

        if force
          mark_dirty!           
        end            

        if is_clean?(revision)
          say_status :snapshot, "It's clean", :yellow
        else
          say_status :snapshot, "Resetting to tag #{revision}", :green          
          with_stopped_database(options) do 
            git.clean

            git.reset_hard(revision)

            mark_clean!(revision)            
          end
        end
      end      
      
      def tag_exists?(tag)
        !!git.tags.detect{|t| t.name == tag}
      end      
      
      private
      
      delegate :mysql_install_db, :database_files_dir, :mysqld_safe, :mysqladmin, :socket, :git, :mysql_defaults_path,:mysql_base_dir, :port, :mysql, :user, :version_file, :pid_file, :to => :configuration

      def with_stopped_database(options = {})
        stop!(options)
        yield
        start!(options)
      end

      def ask_for_new_tag(tag = nil, options = {})
        tag ||= ask_for_tag

        unless options[:force]
          while tag_exists?(tag) && !ask_overwrite_tag(tag)
            tag = ask_for_tag
          end
        end
        
        raise "No tag" unless tag

        tag
      end       

      def ask_for_existing_tag(tag)
        return tag if tag && tag_exists?(tag)
        tag || ask_for_tag_with_menu.to_s 
      end

      def ask_overwrite_tag(tag)
        HighLine.new.agree("The tag #{tag} already exists, overwrite? ")
      end    
      
      def ask_for_tag
        HighLine.new.ask("Specify a tag name: ") do |q|
          q.validate = /^.+$/
        end          
      end      
          
      def ask_for_description(tag)
        HighLine.new.ask("Please provide a short description for (#{tag}): ") do |q|
          q.validate = /^.+$/
        end
      end

      def ask_for_tag_with_menu
        HighLine.new.choose do |menu|
          menu.prompt = "Specify a tag name: "
          each_tag do |tag, description|
            full_description = [tag, description].join("\t" * 4)
            menu.choice(full_description){ tag }
          end
        end
      end    
      
      def is_clean?(revision)        
        if File.exists?(version_file)
          File.read(version_file).strip == revision.to_s
        else
          false
        end
      end  

      def remote_origin_exists?
        git.remotes.first.present?
      end  
            
      def get_tag_description(target)
        each_tag do |tag, description|
          return description if tag == target
        end
      end
      
      def create_remote_origin!
        unless repository
          repository = HighLine.new.ask("Please specify the git repo: ") do |q|
            q.validate = /^ssh:\/\/.+$/
          end     
          say_status :snapshot, "Saving configuration for next time", :green
          configuration.save
        end                  
        unless remote_origin_exists?
          say_status :snapshot,  "adding origin ", :green
          git.add_remote("origin", repository)  
        end
      end        
    end
  end
end