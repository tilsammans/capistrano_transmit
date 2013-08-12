Capistrano::Configuration.instance.load do
  
  _cset :user,        nil
  _cset(:deploy_host) { find_servers(:roles => :db).first.host }
  _cset(:dumpfile)    { "#{current_path}/tmp/#{_db_remote['database']}.sql.gz" }
  
  after "transmit:get:mysql", "transmit:cleanup"
  after "transmit:put:mysql", "transmit:cleanup"

  namespace :transmit do
    namespace :get do
      desc 'Fetch the remote production database and overwrite your local development database with it'
      task :mysql, :roles => :db do
        run "mysqldump --opt --quick --extended-insert --skip-lock-tables #{_remote_db_auth} | gzip > #{dumpfile}"

        system "rsync -vP #{_user_with_host}:#{dumpfile} tmp/#{_db_local["database"]}.sql.gz"
        system "gunzip < tmp/#{_db_local["database"]}.sql.gz | mysql #{_local_db_auth}"
      end

      desc 'Fetch the assets from the production server to the development environment'
      task :assets, :roles => :app do
        system "rsync -Lcrvz #{_user_with_host}:#{current_path}/public ."
      end
    end

    namespace :put do
      desc 'Upload the local development database to the remote production database and overwrite it'
      task :mysql, :roles => :db do
        local_file = "tmp/#{_db_local['database']}.sql.gz"
        system "mysqldump --opt --quick --extended-insert --skip-lock-tables #{_local_db_auth} | gzip > #{local_file}"

        system "rsync -vP #{local_file} #{_user_with_host}:#{dumpfile}"
        run "gunzip < #{dumpfile} | mysql #{_remote_db_auth}"
      end
    end
  
    task :cleanup do
      run "rm #{dumpfile}"
      system "rm tmp/#{_db_local['database']}.sql.gz"
    end
  end

  # Return just the deploy host when user not set.  
  def _user_with_host
    user.nil? ? deploy_host : "#{user}@#{deploy_host}"
  end

  # Output of the entire database.yml on the remote server.
  def _db_config
    @_db_config       ||= capture("cat #{current_path}/config/database.yml")
  end

  # Production database configuration hash.
  def _db_remote
    @_db_remote       ||= YAML::load(_db_config)[stage.to_s]
  end

  # Development database configuration hash.
  def _db_local
    @_db_local        ||= YAML::load_file("config/database.yml")['development']
  end
  
  # Complete remote database connection string.
  def _remote_db_auth
    @_remote_db_auth  ||= "-u #{_db_remote['username']} --password='#{_db_remote['password']}' --host='#{_db_remote['host']}' #{_db_remote['database']}"
  end

  # Complete local database connection string.
  def _local_db_auth
    @_local_db_auth   ||= "-u #{_db_local['username']} --password='#{_db_local['password']}' --host='#{_db_local['host']}' #{_db_local['database']}"
  end
  
end
