
if !!node['engineroom']['db_setup'] == true
	# chef uses the mysql gem to run commands
	gem_package "mysql" do
  	action :install
	end

	conn_info = { :host => 'localhost', :username => 'root', :password => '' }

	# query a database from a sql script on disk
	database 'klosters_d' do
		connection conn_info
		provider Chef::Provider::Database::Mysql
		action :create
	end

end


# Add the bundler package (even though it was added as part of the rvm[system]"
execute 'bundle install' do
  command "gem install bundler"
  not_if do
    File.exists?("/usr/local/rvm/gems/ruby-1.9.3-p327/bin/bundle")
  end
end

execute 'bundle install engineroom' do
  cwd "/vagrant_data/src/engineroom/"
  # path ["/usr/local/rvm/gems/ruby-1.9.3-p327@global/bin","/usr/bin"]
  command "/usr/local/rvm/gems/ruby-1.9.3-p327/bin/bundle install"
           
end

execute 'rake tasks engineroom' do
  cwd "/vagrant_data/src/engineroom/"
  # path ["/usr/local/rvm/gems/ruby-1.9.3-p327@global/bin","/usr/bin"]
  command "rake db:migrate"
           
end

execute 'bundle install rails_admin' do
  cwd "/vagrant_data/src/engineroom/"
  command "/usr/local/rvm/gems/ruby-1.9.3-p327/bin/bundle install --path vendor/gems/e1_rails"       
end

execute 'install thin' do
  command "sudo thin install"
  not_if do
    File.exists?("/etc/rc.d/thin")
  end   
end

# directory "/etc/thin/" do
  # mode 00655
  # action :create
# end

template "/etc/thin/engineroom.yml" do
  source "engineroom/engineroom.yml.erb"
  mode 00655
end

template "/etc/nginx/sites-available/dev.klosters.com.au" do
  source "engineroom/dev.klosters.com.erb"
  mode 00655
end

execute 'make site available' do
  command "sudo ln -s /etc/nginx/sites-available/dev.klosters.com.au /etc/nginx/sites-enabled/dev.klosters.com.au"
  not_if do
    File.exists?("/etc/nginx/sites-enabled/dev.klosters.com.au")
  end   
end

execute 'start up the thin web server' do
  cwd "/vagrant_data/src/engineroom/"
  command "/usr/local/rvm/gems/ruby-1.9.3-p327/bin/bundle exec /etc/rc.d/thin start" 
  not_if do
    File.exists?("/vagrant_data/src/engineroom/tmp/pids/thin.3000.pid" && "/vagrant_data/src/engineroom/tmp/pids/thin.3001.pid" ) 
  end
end


execute 'restart nginx' do
  command "sudo /etc/init.d/nginx restart"
end

