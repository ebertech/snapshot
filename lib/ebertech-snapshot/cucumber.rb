database = EberTech::Snapshot::Configuration.load.database

EberTech::Snapshot::Database.class_eval do
  MARKER = /^@!/
  SAVE_MARKER = /@\+/
  def reset_before_scenario(scenario)
    with_tagged_scenario(scenario) do |tag|
      reset_to!(tag, :single_fork => true)
      mark_dirty!
    end
  end

  def with_tagged_scenario(scenario)
    tag = scenario.tag_names.detect{|tag_name| tag_name =~ MARKER}
    if tag
      tag = tag.gsub(MARKER, "")
      if tag_exists?(tag)
        shell.mute do
          yield tag
        end
        ActiveRecord::Base.establish_connection
      else
        say_status :snapshot, "No such tag: #{tag}, aborting", :red
        exit 1
      end
    end
  end
  
  def with_save_tagged_scenario(scenario)
    tag = scenario.tag_names.detect{|tag_name| tag_name =~ SAVE_MARKER}
    if tag
      tag = tag.gsub(SAVE_MARKER, "")
      shell.mute do
        yield tag
      end
      ActiveRecord::Base.establish_connection
    end
  end  

  def reset_after_cucumber_configuration
    shell.mute do
      mark_dirty!
    end
  end

  def reset_after_scenario(scenario)
    if building?
      with_save_tagged_scenario(scenario) do |tag|
        description = "After #{scenario.title}"
        save_tag!(tag, description, :force => true, :single_fork => true)
      end
    else
      with_tagged_scenario(scenario) do |tag|
        reset_to!(tag, :single_fork => true)
      end
    end
  end

  def building?
    !!ENV["SNAPSHOT_BUILDING"]
  end
end

Cucumber::Ast::Scenario.class_eval do
  def tag_names
    @tags && @tags.instance_eval{ @tag_names }
  end
end

AfterConfiguration do |config|
  database.reset_after_cucumber_configuration
end

Before do |scenario|
  database.reset_before_scenario(scenario)
end

After do |scenario|
  database.reset_after_scenario(scenario)
end
