AfterConfiguration do |config|
  if defined?(ActiveRecord)
    @rails_logger = ActiveRecord::Base.logger
    system("snapshot mark_dirty > /dev/null 2>&1")
  end
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
      @rails_logger.info "Resetting database to #{@database_state}" if @rails_logger
      system("snapshot reset #{@database_state} > /dev/null 2>&1")
      system("snapshot mark_dirty > /dev/null 2>&1")
      ActiveRecord::Base.establish_connection    
    end
  end
end

After do 
  if @database_state && ENV['CLEAN_DATABASE_AFTER_EACH']
    @rails_logger.info "Resetting database to #{@database_state}" if @rails_logger
    `snapshot reset #{@database_state} > /dev/null 2>&1`    
    ActiveRecord::Base.establish_connection
  end
end
