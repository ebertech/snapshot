def run_command_background(command)
  require 'daemons'
  Daemons.daemonize          
  system("#{command}")
end

def run_command(command)
  result = `#{command} 2>&1`          
  return [result, $?]
end

def run_command!(command)
  result = `#{command} 2>&1`  
  raise "Failed #{command}" unless $? == 0        
  return [result, $?]
end

def run_command_and_output(command)
  puts run_command(command).first
end
