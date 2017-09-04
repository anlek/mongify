# Mongify ChangeLog

## 1.3.2 / 04 Sep 2017
* Minor code refactoring
* Removed exception handling around ALL exceptions (this should improve finding issues outside of Mongify)

## 1.3.1 / 09 Nov 2016
* Updated gem requirements to exlucde ActiveRecord/ActiveSupport 5.0
* Locked down gem versions to prevent issues on newer gems (Like ActiveRecord 5 and Mongo)
* Updated README with better markdown
* Updated 'add_dependency' to 'add_runtime_dependency' in gemspec
* Updated some development gems

## 1.3.0 / 07 May 2016
* Updated gem requirements to ActiveRecord 4.2
* Updated type casting to ActiveRecord 4.2 style.
  * NOTE: Timezone is set to UTC by default in the database
* Removed tons of deprication warnings during tests
* Improved contribution set-up rake tasks
* Included Postgres config for Contributors (NOTE: No tests for this)
* Ensured updated_at doesn't get parsed multiple times in `sync` command (thanks @hammady)
* Improved error message during `sync` command (thanks @hammady)
* Minor bug fixes
## 1.2.4 / 29 July 2014
* Fixed bug with ActiveSupport::Autoload (thanks [altieres](https://github.com/anlek/mongify/pull/46))
* Moved the order of reference updating to be second (after copying tables), this way embed tables can use new references
* Small tweak on table.name (making sure rename_to value gets returns first) - It wasn't commited in version 1.2.3
## 1.2.3 / 17 July 2014
* Fixed MS Sql batching issue
* Fixed row.delete requiring you to send in a string (vs symbol)
* ~~Small tweak on table.name (making sure rename_to value gets returns first)~~
## 1.2.2 / 9 July 2014
* Locked in BSON and rspec gem to versions that will work with Mongify
* Updated gems
## 1.2.1 / 16 June 2014
* Fixed polymorphic associations not getting set properly
## 1.2 / 16 June 2014
* Added batching to embedded and polymorphic tables.
* Tweaked progress bar display.
* Fixed issue with embedding
* Updated mongo drivers to version 1.10.2
## 1.1 / 24 March 2014
* Sync feature add (thanks to {hammady}[https://github.com/hammady])
* Parent unset in before_save (tanks to {nessche}[https://github.com/nessche])
* Added batch_size (recommended by {mosheka}[https://github.com/mosheka])
* bugs and performance improvments
## 1.0.1 / 24 December 2013
* Updated and locked down gems to prevent Mongify from breaking when rails gets updated.
## 1.0.0 / 28 May 2013
* Fixed issue with MySql when specifying port (thanks to sebastianmarr)
* Added information Mongify-Mongoid
## 0.9 / 08 Feb 2013
* Changed Mongify Syntax (thanks to tanema)
* Improved error handling
* Improved Test output
* Refactored Commands
* Updated Gem Requirements
* Removed depricated calls (from Mongo insert statement)
* Removed MySql2 dependency (ActiveRecord takes care of that)
## 0.3.1 / 21 Jan 2013
* README examples updated
* README typos fixed.
* Added ability to fetch IDs of fields that have an array of ids
## 0.3 / 12 Sep 2012
* Added ability to work with :key columns that were not :integer values
  * You can now specify :as value for a type :key column
  * Tranlsation generator will prefill :as for :key columns
* Updated README
* Improved tests
* Small refactoring
## 0.2.2 / 11 Sep 2012
* Fix broken specs (Pranas Kiziela)
* Fix translation process when embedding multiple objects (Pranas Kiziela)
* Fix typos (Pranas Kiziela)
* Rake file fixed to work in Ruby 1.8 and Ruby 1.9
## 0.2.1 / 11 Sep 2012
* This version was skipped (internal issues)
## 0.2.0 / 01 Jun 2011
* Added the ability to modify parent table when working with embedded tables
## 0.1.7 / 03 May 2011
* Changed logic to NOT translate columns that are not in the translation file. If column is not listed, it's not moved over.
* Fixed issue with case sensitivity of column names
* Made sure that default value returned is a string (when translating)
* Ensured to_s/to_print would output correct column name (even if it's renamed_to)
## 0.1.6 / 13 Apr 2011
* Removed no longer needed dependencies
* Small tweak to the cucumber tests to ensure correct feedback
* Small changes to the README
## 0.1.5 / 08 Apr 2011
* Removed Gem::Specification#default_executable= from gemspec because it's deprecated with no replacement
* Updated code to work with Ruby 1.9 (thanks to eimermusic for pointing out a ruby 1.9 issue to me)
* Added Rake as a development dependency
* Added new rake tasks: test, test:rspec, test:cucumber
* Updated to newer gems for ActiveSupport and Mongo Drivers.
## 0.1.4 / 04 Mar 2011
* Changed gemspec to point to new homepage at 'http://mongify.com'
* Small change to attempt to fix issue in Ruby 1.9 (Mongify still doesn't work in 1.9, but making a step towards it)
## 0.1.3 / 21 Feb 2011
* Made all exception stem from MongifyError and system always raises a child of MongifyError.
* Brought in the progress bar into source
* Changed behaviour on storing BigDecimal (now converts into String)
* Added ability to convert BigDecimal to integer via an :at => 'integer, :scale => 2 settings.
* Improved Progress Bar display, now it gives you a better feel for what's going on.
* Added an index on pre_mongified_id to speedup lookup times (Making it 42 times faster on import of embedded tables)
* Fixed bug in importing of polymorphic tables where associations are nil
* Fixed bug where pre_mongified_id would be a string and not an integer (causing no updates of ref_ids)
## 0.1.2 / 14 Feb 2011
* More Improvements to README and RDOC
* Added ability to :force => true on a mongodb_connection, forcing it to drop database before processing.
* Improved UI output
* Added activesupport notifications to keep track of what is happening with the system during import.
## 0.1.1 / 28 Jan 2011
* Renamed GenerateDatabase to DatabaseGenerator
* Renamed Table#embed? to Table#embedded?
* Renamed Table#embed_as_object? to Table#embedded_as_object?
* Added support for polymorphic tables
* Did some file cleanup for unused files
## 0.1.0 / 21 Jan 2011
* Moved from Alpha to Beta! :)
* Improved internal RDocs
* Improved specs
* Refactored
* Renamed 'translate' command to 'translation'
* Added :auto_detect option to columns
* Added ability to do a before_save on the table.
## 0.0.9 / 19 Jan 2011
* Added ability to rename tables
* Fixed bug 'pre_mogified_id' not being removed in all records
* Added ability to ignore tables
* Added ability to ignore columns
* Added ability to rename columns
## 0.0.8 / 18 Jan 2011
* Added ability to embed as object on an embedded table
* Some bugs fixed
* Updated README with new table options
* Improved data conversion on processing
## 0.0.7 / 17 Jan 2011
* Added mysql2 as a dependency
* Improved error message when configuration file not provided
* More detailed README file
* Removed :default flag for column (there was no need for this)
* Removed 'pre_mongified_id' from all collections (including embedded)
* Removed the parent_id from an embedded row
## 0.0.6 / 16 Jan 2011
* Added the ability to embed tables into collections (currently only one to many relationship)
* Few tweaks and improvements in code
## 0.0.5 / 15 Jan 2011
* Improved description for mongify.
## 0.0.4 / 15 Jan 2011
* Switched the way connection files are written out.
* Fixed issue with Configuration File reader
* Added a Rake task to setup a mysql database for testing (for development only)
* Added a way to create a translation file from a sql configuration
* Added a printer ability for translation and command
* Added MongoDB connection
* Improved test coverage
* Added the first version of processing command (very basic)
* Indexed columns in table class to speedup lookup time
* Added ability to update references once database is populated
## 0.0.3 / 28 Dec 2010
* Switched gemspec generation to raw gemspec and added Bundler for easier development
* Added LICENSE
* Cleaned up the require statements through out the app
## 0.0.2 / 09 Jun 2010
* Rewrote the whole CLI interface
* Removed datamapper and added active_record
* Improved tests to cover most of the code
* Changed overall commands for Mongify
## 0.0.1 / 22 Mar 2010
* Initial Setup