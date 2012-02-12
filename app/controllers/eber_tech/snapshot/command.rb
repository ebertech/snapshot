module EberTech
  module Snapshot
    class Command < Clamp::Command      
      subcommand "init", %Q{Creates the data_dir, initializes the database and setups up a git repository and commits the state of the newly created database to it.}, InitCommand      
      subcommand "list", %Q{List revisions in the database}, ListRevisionsCommand      
      subcommand "tags", %Q{List tags in the database}, ListTagsCommand      
      subcommand "mark_clean", %Q{Marks the database as at a given state}, MarkCleanCommand      
      subcommand "mark_dirty", %Q{Marks the database as needing to be reset}, MarkDirtyCommand      
      subcommand "migrate", %Q{Migrate all tags using the current migrations}, MigrateCommand      
      subcommand "pull", %Q{Pull from a remote repository}, PullCommand      
      subcommand "push", %Q{Push to a remote repository}, PushCommand      
      subcommand "remove", %Q{Removes a given tag from the repository}, RemoveTagCommand      
      subcommand "reset", %Q{Resets the database to a given revision or tag. Starts and stops the db in the process}, ResetCommand      
      subcommand "save", %Q{Saves the database to a given revision or tag. Starts and stops the db in the process}, SaveCommand      
      subcommand "start", %Q{Start the database}, StartDatabaseCommand      
      subcommand "stop", %Q{Stop the database}, StopDatabaseCommand      
      subcommand "status", %Q{Get the status of the database}, StatusCommand      
    end
  end
end