module EberTech
  module Snapshot
    module Commands
      class CreateConfigCommand < ::EberTech::Snapshot::Command
        def self.command_name
          "create_config"
        end
        def self.execute(arguments)
          FileUtils.mkdir_p("config")
          if File.exists?(configuration_path)
            if arguments.first == "-f"
              puts "Overwriting #{configuration_path}"
            else
              puts "File #{configuration_path} exists, force overwrite with -f"
              exit(1)
            end
          end
          File.open(configuration_path, "w+") do |file|
            file << "port: 3307\n"
            file << "datadir: db/test_data\n"
            file << "git: /usr/local/bin/git\n"
            file << "mysqld_safe: /usr/local/mysql/bin/mysqld_safe\n"
            file << "mysql_admin: /usr/local/mysql/bin/mysqladmin\n"
            file << "mysql_install_db: /usr/local/mysql/bin/mysql_install_db\n"
          end
        end

      end
    end
  end
end