# main Rake file

require 'rake'

# hack : we re-use the webapp conf,
# so we need to overload sinatra dsl
def helpers; end
def before; end
def get(*args); end
def post(*args); end
def set(*args); end
# make sure the config block is executed
def configure; yield; end

# load our app
require(File.join(File.dirname(__FILE__), 'intranet'))

# load rake files
Dir[File.dirname(__FILE__) + "/scripts/rake/*.rb"].each{|r| require r}

task :default do
  puts "forgot something ?"
end

