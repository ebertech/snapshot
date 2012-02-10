class EberTech::Snapshot::Generator < Thor::Group
  include Thor::Actions
  include EberTech::CommandLine::Actions  
  include MysqlActions
  include GitActions

  attr_accessor :configuration

  def self.source_root
    File.expand_path("../../../../views", __FILE__)
  end
  
  def initialize_snapshot
    #TODO check existing
    #db/test_data/database_files/mysql/db.MYD
    options[:environment_name] =  ask_environment_name  
    options[:database] = ask_database_name  
    options[:username] = ask_database_username      
    options[:port] = ask_port

    [
      :mysql_install_db, 
      :mysqld_safe,
      :mysql, 
      :git,
      :mysqladmin
    ].each do |command|
      options[command] = which(command.to_s) || raise("Can't find #{command} in path")
    end  
      
    template "snapshot.yml", snapshot_yml_path      
    template "database.yml", database_yml_path
    template "mysql_conf_template.erb", mysql_defaults_path    

    self.configuration = ::EberTech::Snapshot::Configuration.load

    empty_directory database_files_dir

    create_database   
    database.start! 
    grant_access
    create_git_repository

    empty_directory File.dirname(pid_file)
    empty_directory File.dirname(log_file)
    empty_directory File.dirname(socket)
    empty_directory File.dirname(error_log_file)        
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
  
  def mysql_defaults_path
    File.join(rails_config_dir, "mysql.conf")
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

  def ask_environment_name
    HighLine.new.ask("Environment: ") do |question|
      question.default = "development"
    end
  end

  def ask_database_username
    HighLine.new.ask("Username: ") do |question|
      question.default = "root"
    end
  end  
  
  def rails_config_dir
    File.join("config")
  end

  def database_yml_path
    File.join(rails_config_dir, "database.yml") 
  end  

  def snapshot_yml_path
    File.join(rails_config_dir, "snapshot.yml")       
  end

  def socket
    File.join("tmp", "sockets", "snapshot_socket")
  end
end