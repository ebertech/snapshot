class EberTech::Snapshot::Generator < Thor::Group
  include Thor::Actions
  include EberTech::CommandLine::Actions  
  include EberTech::Snapshot::MysqlActions
  include EberTech::Snapshot::GitActions
  include EberTech::Snapshot::RakeActions

  attr_accessor :configuration
  [:environment_name, 
    :database, 
    :username, 
    :port, 
    :mysql_install_db, 
    :mysqld_safe,
    :mysql, 
    :git,
    :adapter,
    :mysqladmin
  ].each do |a|
    attr_accessor a
  end

  def self.source_root
    File.expand_path("../../../../views", __FILE__)
  end

  def initialize_snapshot
    [
      :mysql_install_db, 
      :mysqld_safe,
      :mysql, 
      :git,
      :mysqladmin
    ].each do |command|
      self.send(:"#{command}=", which(command.to_s) || raise("Can't find #{command} in path"))
    end

    self.configuration = find_or_create_configuration
    
    if !configuration || !configuration.database_exists? || options[:force] || handle_conflict(configuration)
      if configuration
        configuration.database.stop!       
        say_status :delete, data_dir, :red
        FileUtils.rm_rf(data_dir)
      end
            
      self.port = ask_port.to_i    
      self.port = nil if port.zero?


      self.environment_name =  ask_environment_name
      self.environment_name = "cucumber"  if self.environment_name.blank?      
      self.database = ask_database_name  
      self.adapter = ask_database_adapter
      self.username = ask_database_username    
      template "snapshot.yml", snapshot_yml_path               
      self.configuration = ::EberTech::Snapshot::Configuration.load  

      raise "Can't load configuration" unless self.configuration    

      template "database.yml", configuration.database_yml_path      
      
      empty_directory File.dirname(pid_file)
      empty_directory File.dirname(log_file)
      empty_directory File.dirname(socket)
      empty_directory File.dirname(error_log_file)      
      
      template "mysql_conf_template.erb", mysql_defaults_path    

      empty_directory database_files_dir

      configuration.database.create!

      configuration.database.start! 
      configuration.database.grant!

      rake_task "db:create"
      rake_task "db:schema:load"    
      create_git_repository
      configuration.database.save_tag!("schema_loaded", "The schema is clean")    
    end
  end

  def find_or_create_configuration
    ::EberTech::Snapshot::Configuration.load    
  end

  def handle_conflict(configuration)
    say_status :snapshot, "Snapshot already exists", :red
    shell.file_collision(configuration.snapshot_config_dir)
  end

  def pretend?
    options[:pretend]
  end

  private

  def method_missing(method, *args)
    if !options[method].nil?
      options[method]
    elsif configuration.respond_to?(method)
      configuration.send(method, *args)
    else
      super
    end
  end

  def ask_database_name
    HighLine.new.ask("Database name: ") do |question|
      if File.exists?("Ebermin")
        question.default = YAML.load(File.read("Ebermin"))["project"]
      end
    end
  end

  def ask_port
    HighLine.new.ask("Port to listen on (leave blank to disable): ") do |question|
      question.default = ""
    end    
  end

  def ask_database_adapter
    HighLine.new.ask("Which adapter do you want to use: ") do |question|
      question.default = "mysql"
    end    
  end

  def ask_environment_name
    HighLine.new.ask("Environment: ") do |question|
      question.default = environment_name || "cucumber"
    end
  end

  def ask_database_username
    HighLine.new.ask("Username: ") do |question|
      question.default = "root"
    end
  end  

  def snapshot_yml_path
     ::EberTech::Snapshot::Configuration.default_configuration_path    
  end
end