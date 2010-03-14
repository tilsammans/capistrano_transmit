set(:db_remote) do
  db_config = capture "cat #{current_path}/config/database.yml"
  YAML::load(db_config)['production']
end

set(:db_local) do
  YAML::load_file("config/database.yml")['development']
end

desc 'Fetch the remote production database and overwrite your local development database with it'
namespace :db do
  task :fetch, :roles => :db do
    dumpfile = "#{current_path}/tmp/#{db_remote['database']}.sql"
    run "mysqldump --opt -u #{db_remote['username']} --password=#{db_remote['password']} -h #{db_remote['host']} #{db_remote['database']} > #{dumpfile}"

    system "rsync -vP #{user}@#{deploy_host}:#{dumpfile} tmp/#{db_local["database"]}.sql"
    system "mysql -u #{db_local['username']} --password=#{db_local['password']} #{db_local['database']} < tmp/#{db_local["database"]}.sql"

    run "rm #{dumpfile}"
    system "rm tmp/#{db_local["database"]}.sql"
  end
end
