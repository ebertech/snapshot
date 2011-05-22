Probably should put things into a proper API so that you can just call

Snapshot.reset_to!(tag)
Snapshot.mark_dirty!

etc etc.

Also need to be able to re-seed.

This should also be pulled out so that the generator runs by itself without having to do script/generate
  
General pattern for any project should be


snapshot init (which calls the snapshot generator)
rake db:create
rake db:migrate
snapshot save schema_loaded
rake db:seed
snapshot save seeded


seeds should be idempotent