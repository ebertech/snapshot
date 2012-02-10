AfterConfiguration do |config|
  puts "[SNAPSHOT] Marking DB for cleaning"
  EberTech::CommandHelper.run_command("snapshot mark_dirty")
end

Before do |scenario|
  def scenario.tags 
    @tags
  end
  tags = scenario.tags
  if tags
    def tags.tag_names
      @tag_names
    end
    tag = tags.tag_names.detect{|t| t =~ /^@db_state/}
    if tag    
      @database_state = tag.split(".").last
      puts "    [SNAPSHOT] Resetting database to #{@database_state}" 
      EberTech::CommandHelper.run_command("snapshot reset #{@database_state}")
      EberTech::CommandHelper.run_command("snapshot mark_dirty")

      ActiveRecord::Base.establish_connection    
    end
  end
end

After do 
  if @database_state && ENV['CLEAN_DATABASE_AFTER_EACH']
    EberTech::CommandHelper.run_command("snapshot reset #{@database_state}")
    ActiveRecord::Base.establish_connection
  end
end
