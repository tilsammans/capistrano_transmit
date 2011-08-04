unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/transmit requires Capistrano 2"
end

Capistrano::Configuration.instance.load do
  
  _cset :user,        nil
  _cset(:deploy_host) { find_servers(:roles => :db).first.host }
  _cset(:db_config)   { capture("cat #{current_path}/config/database.yml") }
  _cset(:db_remote)   { YAML::load(db_config)['production'] }
  _cset(:db_local)    { YAML::load_file("config/database.yml")['development'] }
  _cset(:dumpfile)    { "#{current_path}/tmp/#{db_remote['database']}.sql.gz" }
  
  after "transmit:get:mysql", "transmit:cleanup"
  after "transmit:put:mysql", "transmit:cleanup"

  # Return just the deploy host when user not set.  
  def _user_with_host
    user.nil? ? deploy_host : "#{user}@#{deploy_host}"
  end

  namespace :transmit do
    namespace :get do
      desc 'Fetch the remote production database and overwrite your local development database with it'
      task :mysql, :roles => :db do
        run "mysqldump --opt --quick --extended-insert --skip-lock-tables -u #{db_remote['username']} --password='#{db_remote['password']}' --host='#{db_remote['host']}' #{db_remote['database']} | gzip > #{dumpfile}"

        system "rsync -vP #{_user_with_host}:#{dumpfile} tmp/#{db_local["database"]}.sql.gz"
        system "gunzip < tmp/#{db_local["database"]}.sql.gz | mysql -u #{db_local['username']} --password='#{db_local['password']}' --host='#{db_local['host']}' #{db_local['database']}"
      end

      desc 'Fetch the assets from the production server to the development environment'
      task :assets, :roles => :app do
        system "rsync -Lcrvz #{_user_with_host}:#{current_path}/public ."
      end
    end

    namespace :put do
      desc 'Upload the local development database to the remote production database and overwrite it'
      task :mysql, :roles => :db do
        system "mysqldump --opt -u #{db_local['username']} --password='#{db_local['password']}' --host='#{db_local['host']}' #{db_local['database']} > tmp/#{db_local['database']}.sql"

        system "rsync -vP tmp/#{db_local['database']}.sql #{_user_with_host}:#{dumpfile}"
        run "mysql -u #{db_remote['username']} --password='#{db_remote['password']}' --host='#{db_remote['host']}' #{db_remote['database']} < #{dumpfile}"
      end
    end
  
    task :cleanup do
      run "rm #{dumpfile}"
      system "rm tmp/#{db_local['database']}.sql.gz"
    end
  end

end
