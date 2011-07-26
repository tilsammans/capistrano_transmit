after "transmit:get:mysql", "transmit:cleanup"
after "transmit:put:mysql", "transmit:cleanup"

namespace :transmit do
  namespace :get do
    desc 'Fetch the remote production database and overwrite your local development database with it'
    task :mysql, :roles => :db do
      run "mysqldump --opt --quick --extended-insert --skip-lock-tables -u #{db_remote['username']} --password='#{db_remote['password']}' -h #{db_remote['host']} #{db_remote['database']} | gzip > #{dumpfile}"

      system "rsync -vP #{user}@#{deploy_host}:#{dumpfile} tmp/#{db_local["database"]}.sql.gz"
      system "gunzip < tmp/#{db_local["database"]}.sql.gz | mysql -u #{db_local['username']} --password='#{db_local['password']}' --host='#{db_local['host']}' #{db_local['database']}"
    end

    desc 'Fetch the assets from the production server to the development environment'
    task :assets, :roles => :app do
      system "rsync -Lcrvz #{user}@#{deploy_host}:#{current_path}/public ."
    end
  end

  namespace :put do
    desc 'Upload the local development database to the remote production database and overwrite it'
    task :mysql, :roles => :db do
      system "mysqldump --opt -u #{db_local['username']} --password='#{db_local['password']}' #{db_local['database']} > tmp/#{db_local['database']}.sql"

      system "rsync -vP tmp/#{db_local['database']}.sql #{user}@#{deploy_host}:#{dumpfile}"
      run "mysql -u #{db_remote['username']} --password='#{db_remote['password']}' -h #{db_remote['host']} #{db_remote['database']} < #{dumpfile}"
    end
  end
  
  task :cleanup do
    run "rm #{dumpfile}"
    system "rm tmp/#{db_local['database']}.sql.gz"
  end
end

set(:db_remote) do
  db_config = capture "cat #{current_path}/config/database.yml"
  YAML::load(db_config)['production']
end

set(:db_local) do
  YAML::load_file("config/database.yml")['development']
end

set :dumpfile do
  "#{current_path}/tmp/#{db_remote['database']}.sql.gz"
end
