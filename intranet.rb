# Our sinatra application - main entry point
# load classes and initialize connections

# extra, aka monkey patches
%w(string date time).each do |f|
  require(File.join(File.dirname(__FILE__), 'extra', f))
end

# domain classes
%w(user group post).each do |f|
  require(File.join(File.dirname(__FILE__), 'domain', f))
end

# controllers (sinatra routes)
%w(helper main account users admin api_v1).each do |f|
  require(File.join(File.dirname(__FILE__), 'controller', f))
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
  set :posts_per_page, 10

  # ldap connection
  ldap_config = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/ldap.yml")).result)
  ActiveLdap::Base.setup_connection ldap_config

  # mongodb connection
  mongo_config = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/config/mongo.yml")).result)
  MongoMapper.connection = Mongo::Connection.new(mongo_config['host'], mongo_config['port'])
  MongoMapper.database = mongo_config['db']
end

