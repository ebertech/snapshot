configuration = ::EberTech::Snapshot::Configuration.new          
run_command_and_output("cd #{configuration.data_dir} && #{configuration.git} log")          
