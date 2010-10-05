module EberTech
  module Snapshot
    module Commands
      class Init < ::EberTech::Snapshot::Command
        def self.command_name
          "init"
        end
        def self.execute(arguments)
          configuration = ::EberTech::Snapshot::Configuration
          configuration.load
          FileUtils.mkdir_p(configuration.data_dir)
          # mysql_install_db --user=$user? --datadir=$pwd/db/test_data --ldata=$pwd/db/test_data
          run_command("#{configuration.mysql_install_db} --datadir='#{configuration.data_dir}'  --ldata='#{configuration.data_dir}'")
          run_command("cd #{configuration.data_dir} && #{configuration.git} init && #{configuration.git} add . && #{configuration.git} commit -m 'initial commit'")          
        end
      end
    end
  end
end