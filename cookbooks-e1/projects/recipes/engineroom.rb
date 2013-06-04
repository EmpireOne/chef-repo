
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


# # Add the bundler package (even though it was added as part of the rvm[system]"
# execute 'bundle install' do
  # command "sudo gem install bundler"
  # not_if do
    # File.exists?("/usr/local/rvm/gems/ruby-1.9.3-p392/bin/bundle")
  # end
# end

# execute 'bundle install engineroom' do
  # cwd "/vagrant_data/src/engineroom/"
  # # path ["/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin","/usr/bin"]
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392/bin/bundle install"
           
# end

# execute 'rake tasks engineroom' do
  # cwd "/vagrant_data/src/engineroom/"
  # # path ["/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin","/usr/bin"]
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392/bin/bundle exec rake db:migrate"
           
# end

# execute 'bundle install rails_admin' do
  # cwd "/vagrant_data/src/engineroom/vendor/gems/e1_rails/"
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392/bin/bundle install"       
# end

# execute 'install thin' do
  # command "sudo thin install"
  # not_if do
    # File.exists?("/etc/rc.d/thin")
  # end   
# end

# directory "/etc/thin/" do
  # mode 00655
  # action :create
# end

# template "/etc/thin/engineroom.yml" do
  # source "engineroom/engineroom.yml.erb"
  # mode 00655
# end

template "/etc/nginx/sites-available/local.klosters.com.au" do
  source "engineroom/local.klosters.com.au.erb"
  mode 00655
end

execute 'make site available' do
  command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.klosters.com.au"
  not_if do
    File.exists?("/etc/nginx/sites-enabled/local.klosters.com.au")
  end   
end

execute 'make site available' do
  command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.klostersford.com.au"
  not_if do
    File.exists?("/etc/nginx/sites-enabled/local.klostersford.com.au")
  end   
end

execute 'make site available' do
  command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.klostersvolkswagen.com.au"
  not_if do
    File.exists?("/etc/nginx/sites-enabled/local.klostersvolkswagen.com.au")
  end   
end

execute 'make site available' do
  command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.lakevolkswagen.com.au"
  not_if do
    File.exists?("/etc/nginx/sites-enabled/local.lakevolkswagen.com.au")
  end   
end

# execute 'start up the thin web server' do
  # cwd "/vagrant_data/src/engineroom/"
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin/bundle exec /etc/rc.d/thin start" 
  # not_if do
    # File.exists?("/vagrant_data/src/engineroom/tmp/pids/thin.3000.pid"  ) 
  # end
# end


execute 'restart nginx' do
  command "sudo /etc/init.d/nginx restart"
end

