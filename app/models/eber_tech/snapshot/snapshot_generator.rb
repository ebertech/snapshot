class SnapshotGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  attr_accessor :port
  attr_accessor :environment_name
  attr_accessor :username
  attr_accessor :database
  
  def initialize_snapshot
    self.environment_name =  ask_environment_name  
    self.database = ask_database_name  
    self.username = ask_database_username      
    self.port = ask_port      

    create_snapshot_support!
    create_snapshot_yml!
    create_database_yml!
  end

  private

  def create_database_yml!
    dir = File.join("config")
    file = File.join(dir, "database.yml") 

    template "database.yml", file
  end  
  
  def socket
    File.join("tmp", "sockets", "snapshot_socket")
  end

  def create_snapshot_support!
    dir = File.join("features", "support")
    file = File.join(dir, "snapshot.rb") 
    template "snapshot.rb", file       
  end

  def create_snapshot_yml!
    dir = File.join("config")
    file = File.join(dir, "snapshot.yml") 
    template "snapshot.yml", file
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
end