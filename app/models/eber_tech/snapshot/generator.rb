class EberTech::Snapshot::Generator < Thor::Group
  include Thor::Actions
  include EberTech::CommandLine::Actions  
  
  attr_accessor :configuration

  def self.source_root
    File.expand_path("../../../../views", __FILE__)
  end
    
  def initialize_snapshot
    create_snapshot_yml!
    create_database_yml!

    self.configuration = ::EberTech::Snapshot::Configuration.new

    empty_directory database_files_dir
    
    create_database
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
  
  class MysqlAdminCreateDatabase
    attr_accessor :base, :mysql_install_db, :database_files_dir, :mysql_base_dir

    def initialize(base, mysql_install_db, database_files_dir, mysql_base_dir, config = {})
      self.base = base
      self.mysql_install_db = mysql_install_db
      self.database_files_dir = database_files_dir       
      self.mysql_base_dir = mysql_base_dir   
    end
    
    def invoke!      
      base.run(mysql_install_db, ["--datadir='#{database_files_dir}'", "--ldata='#{database_files_dir}'", "--basedir='#{mysql_base_dir}'"])
    end
  end
  
  class GitRepository
    attr_accessor :base, :data_dir
    
    def initialize(base, data_dir)
      self.base = base
      self.data_dir = data_dir
    end
    
    def invoke!
      base.say_status :git, data_dir, :green
      return if base.pretend?
      Git.init(data_dir).tap do |g|
        g.add(data_dir)
        g.commit("initial commit") 
      end
    end
  end
  
  def create_git_repository
    action GitRepository.new(self, data_dir)    
  end
  
  def create_database
    action MysqlAdminCreateDatabase.new(self, mysql_install_db, database_files_dir, mysql_base_dir)
  end
  
  def method_missing(method, *args)
    if !options[method].nil?
      options[method]
    elsif configuration.respond_to?(method)
      configuration.send(method, *args)
    else
      super
    end
  end

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
end