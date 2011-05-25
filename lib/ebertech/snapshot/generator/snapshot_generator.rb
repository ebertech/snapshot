require 'highline'
class SnapshotGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      environment_name =  ask_environment_name  
      database = ask_database_name  
      username = ask_database_username      
      port = ask_port      
      create_snapshot_support!(m)
      create_snapshot_yml!(m, port)
      create_database_yml!(m, environment_name, database, username, port)
    end
  end
  private

  def create_database_yml!(m, environment_name, database, username, port)
    socket = File.join("tmp", "sockets", "snapshot_socket")
    
    dir = File.join("config")
    file = File.join(dir, "database.yml") 
    m.directory dir
    m.template "database.yml", file, :assigns => {:environment_name => environment_name, :database => database, :username => username, :socket => socket, :port => port}      
  end  

  def create_snapshot_support!(m)
    dir = File.join("features", "support")
    file = File.join(dir, "snapshot.rb") 
    m.directory dir
    m.template "snapshot.rb", file       
  end

  def create_snapshot_yml!(m, port)
    dir = File.join("config")
    file = File.join(dir, "snapshot.yml") 
    m.directory dir
    m.template "snapshot.yml", file, :assigns => {:port => port}      
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