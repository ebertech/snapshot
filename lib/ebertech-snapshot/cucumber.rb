database = EberTech::Snapshot::Configuration.load.database

AfterConfiguration do |config|
  database.mark_dirty
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
      database.reset!(@database_state)
      database.mark_dirty!
      ActiveRecord::Base.establish_connection    
    end
  end
end

After do 
  if @database_state && ENV['CLEAN_DATABASE_AFTER_EACH']    
    database.reset!(database_state)    
    ActiveRecord::Base.establish_connection
  end
end
