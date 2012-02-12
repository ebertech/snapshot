database = EberTech::Snapshot::Configuration.load.database

EberTech::Snapshot::Database.class_eval do
  MARKER = /^@!/
  def reset_before_scenario(scenario)
    with_tagged_scenario(scenario) do |tag|
      shell.mute do 
        reset_to!(tag, :single_fork => true)
        mark_dirty!
      end
      ActiveRecord::Base.establish_connection          
    end
  end

  def with_tagged_scenario(scenario)
    tag = scenario.tag_names.detect{|tag_name| tag_name =~ MARKER}
    if tag    
      tag = tag.gsub(MARKER, "") 
      if tag_exists?(tag)
        yield tag
      else
        say_status :snapshot, "No such tag: #{tag}, ignoring", :yellow
      end
    end    
  end

  def reset_after_scenario(scenario)
    with_tagged_scenario(scenario) do |tag|
      shell.mute do 
        reset_to!(tag, :single_fork => true)      
      end
      ActiveRecord::Base.establish_connection
    end
  end
end

Cucumber::Ast::Scenario.class_eval do
  def tag_names
    @tags && @tags.instance_eval{ @tag_names }
  end
end

AfterConfiguration do |config|
  database.mark_dirty!
end

Before do |scenario|
  database.reset_before_scenario(scenario)
end

After do |scenario|
  database.reset_after_scenario(scenario)
end
