# Our sinatra application - main entry point
# load classes and initialize connections

# external third-party libs
%w(md5 sanitize babosa).each{ |lib| require lib }

# extra, aka monkey patches
%w(string date time).each do |f|
  require(File.join(File.dirname(__FILE__), 'extra', f))
end

# domain classes
%w(user group post event participation).each do |f|
  require(File.join(File.dirname(__FILE__), 'domain', f))
end

# controllers (sinatra routes)
%w(helper main account users posts events admin api_v1).each do |f|
  require(File.join(File.dirname(__FILE__), 'controller', f))
end

# helper method for loading a config file in YAML
def load_yaml_config(yaml_config_file_name)
  YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/#{yaml_config_file_name}.yml")).result) rescue {}
end

# initialization
configure do
  # git status
  git_branch = `git branch | grep '*' | awk '{print $2}'`.strip
  git_infos = `git log HEAD^1..HEAD --pretty=format:"%h|%H|%ai|%cn"`.split('|')
  # status variables
  set :start_time, Time.now
  set :git_branch, git_branch
  set :git_version, git_infos[0]
  set :git_version_full, git_infos[1]
  set :git_version_date, Time.parse(git_infos[2])
  set :git_version_author, git_infos[3]

  # app config
  load_yaml_config('application').each{|k,v| set k.to_sym, v}

  # ldap connection
  ActiveLdap::Base.setup_connection load_yaml_config('ldap')

  # mongodb connection
  mongo_config = load_yaml_config 'mongo'
  MongoMapper.connection = Mongo::Connection.new(mongo_config['host'], mongo_config['port'])
  MongoMapper.database = mongo_config['db']
end

