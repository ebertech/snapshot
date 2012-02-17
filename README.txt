SNAPSHOT
============
If building set the following environment variable:

SNAPSHOT_BUILDING=true

@!tag_name resets the db to tag_name BEFORE the scenario
@+tag_name saves the database AFTER the scenario to tag_name




Also need to be able to re-seed.

General pattern for any project should be

snapshot init (which calls the snapshot generator)
rake db:create
rake db:migrate
snapshot save schema_loaded
 (DONE)

rake db:seed
snapshot save seeded


seeds should be idempotent


NEW TODOS

save snapshot.cnf and my.cnf in db/test_data in config 
save the port and environment in snapshot.cnf
make sure to pass environment to rake db:migrate
in the status command show the currently checked out revision

Need some way to figure out the dependency tree and walk it depth first
maybe use that for the tree structure in the admin section? 

use git notes to set the parent child relationships

git notes add -m "test2"  -f
git notes show
git notes remove

When saving you can figure out who the parent is based on what was last checked out
which you do by getting the HEAD and figuring out its tag

This way the walking of the dependency tree is easy
To re-create the scenarios you'd just do a depth-first traversal of the snapshot tree
if there's a scenario that creates the current tag run it
else recurse on children

to build tree just iterate through the tags and link everything up

Can also use this to calculate the most efficient path through the tests, that is, the path that uses the least snapshot resets
You can also use the transactional database cleaner to make sure things are exactly as they were 

maybe use a custom printer and save a rerun.txt file
the format is

path:line_number