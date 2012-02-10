class Tag
  class << self
    def all
      
    end
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
  
end