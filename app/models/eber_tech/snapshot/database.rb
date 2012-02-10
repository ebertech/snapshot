module EberTech
  module Snapshot
    class Database < Thor::Group
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
          with_stopped_database do                
            mark_dirty!
            reset_to!(tag)
            rake_task("db:migrate")
            save_tag!(tag, :force => true)
          end
        end
      end

      def stop!(options = {})
        stop_database!(mysql_admin, socket)
      end

      def start!(options = {})
        start_database!(mysqld_safe, mysql_admin, socket)
      end

      def pull!(options = {})
        create_remote_origin!

        #fetch -f --tags origin master
        git.fetch("origin")

        #pull -f origin master
        git.pull("origin", "master")
      end

      def push!(options = {})
        create_remote_origin!
        git.push("origin", "master", true)  
      end

      def save_tag!(tag, description, options = {})
        say_status :snapshot,  "Saving tag #{tag}", :green        
        with_stopped_database do
          git.add(".")
          git.commit(description)
          git.tag(tag)
        end
      end

      def reset_to!(revision, options = {})

        force = options[:force]       
        revision ||= ask_for_existing_tag     

        if force
          mark_dirty!           
        end            

        if is_clean?(revision)
          say_status :snapshot, "It's clean", :yellow
        else
          say_status :snapshot, "Resetting to tag #{tag}", :green          
          with_stopped_database do 
            #clean -d -f
            git.clean

            git.reset_hard(revision)

            mark_clean!(revision)            
          end
        end
      end      

      private

      def with_stopped_database
        stop!
        yield
        start!
      end

      def ask_for_new_tag(tag = nil)
        tag ||= ask_for_tag

        while tag_exists?(tag) && !ask_overwrite_tag(tag)
          tag = ask_for_tag
        end

        tag
      end       

      def ask_for_existing_tag(tag)
        return tag if tag && tag_exists?(tag)
        tag || ask_for_tag_with_menu  
      end

      def ask_overwrite_tag(tag)
        HighLine.new.agree("The tag #{tag} already exists, overwrite? ")
      end        

      def tag_exists?(tag)

      end        

      def ask_for_tag
        HighLine.new.ask("Specify a tag name: ") do |q|
          q.validate = /^.+$/
        end          
      end 

      def get_tag_description(tag)

      end

      def ask_for_tag_with_menu
        HighLine.new.choose do |menu|
          menu.prompt = "Specify a tag name: "
          each_tag do |tag, description|
            menu.choice tag
          end
        end
      end

      def get_tag_revision(tag)

      end        

      def is_clean?(revision)        
        if File.exists?(version_file)
          File.read(version_file).strip == revision.to_s
        else
          false
        end
      end  

      def remove_tag!(tag)

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

      def git
        configuration.git
      end

      def remote_origin_exists?
        git.remotes.first.present?
      end

      def ask_for_description
        HighLine.new.ask("Please provide a short description: ") do |q|
          q.validate = /^.+$/
        end
      end      
    end
  end
end