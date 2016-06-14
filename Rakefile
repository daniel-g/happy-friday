# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'framework'
require 'framework/rake'

Dir["#{Dir.pwd}/app/tasks/**/*.rake"].each(&method(:load))
