package "ImageMagick"

if !!node['engineroom']['db_setup'] == true
	# chef uses the mysql gem to run commands
	gem_package "mysql" do
		action :install
	end

	conn_info = { :host => 'localhost', :username => 'root', :password => '' }

	# query a database from a sql script on disk
	mysql_database 'klosters_d' do
		connection conn_info
		provider Chef::Provider::Database::Mysql
		action :create
	end

end



# execute 'ssh_keys empireone' do
  # command %Q{
	# env=dev
	# curl --write-out %{http_code} https://raw.github.com/EmpireOne/ssh_keys/master/setup.sh --output ~/setup.sh 2> /dev/null | grep 200 > /dev/null && bash ~/setup.sh $env && rm ~/setup.sh > /dev/null 2>&1
  # }
# end

# execute 'set rsa key' do
	# cwd "~/.ssh/"
	# command "curl http://deploy:zaqq1590@chef.empireone.com.au/id_rsa > id_rsa"
# end

remote_file '/home/vagrant/.ssh/id_rsa' do
  source 'https://dl.dropboxusercontent.com/s/7s09htg6mlhjgxf/id_rsa'
  mode 00700
  not_if do
    File.exists?("/home/vagrant/.ssh/id_rsa")
  end
end

directory "/usr/local/sshwrapper" do
  recursive true
end

cookbook_file "/usr/local/sshwrapper/wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh"
  mode 00700
end


directory "/vagrant_data/src" do
  owner 'vagrant'
  group 'vagrant'
  mode 00700
  recursive true
  action :create
end

git '/vagrant_data/src/engineroom/' do
  repository "git@git.assembla.com:engineroom.git"
  reference "master"
  action :sync
  ssh_wrapper "/usr/local/sshwrapper/wrap-ssh4git.sh"
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

# gem_package "bundler" do
	# action :install
# end



#execute 'bundle install engineroom' do
 # cwd "/vagrant_data/src/engineroom/"
#  path ["/usr/local/rvm/rubies/default/bin"]
  #user "vagrant"
 # action :run
  #group "sysadmin"
 # command "/usr/local/rvm/rubies/default/bin/bundle install"
 
 #command "bundle install"
#end
 rvm_shell "Bundle install" do
	ruby_string "ruby-1.9.3-p392@global"
	cwd "/vagrant_data/src/engineroom"
	#user app[:deploy_user]
	#group app[:deploy_user]
 
# common_groups = %w{development test cucumber}
# bundle install --deployment --path #{app[:app_root]}/shared/bundle --without #{common_groups.join(' ')}
#	bundle install --path #{app[:app_root]}/shared/bundle
 
code %{
	bundle install
}
end


# execute 'rake tasks engineroom' do
  # cwd "/vagrant_data/src/engineroom/"
  # # path ["/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin","/usr/bin"]
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392/bin/bundle exec rake db:migrate"
           
# end
rvm_shell "start solr instance" do
	ruby_string "ruby-1.9.3-p392@global"
	cwd "/vagrant_data/src/engineroom"
code %{
	rake sunspot:solr:start
	
}
not_if { ::File.exists?("/vagrant_data/src/engineroom/solr/pids/development/sunspot-solr-development.pid") }
end



rvm_shell "rake db:migrate" do
	ruby_string "ruby-1.9.3-p392@global"
	cwd "/vagrant_data/src/engineroom"
code %{
	rake db:migrate
	rake load:permissions
	rake load:cars
	rake load:kloster
	yes | rake sunspot:solr:reindex
}
end

# execute 'bundle install rails_admin' do
  # cwd "/vagrant_data/src/engineroom/vendor/gems/e1_rails/"
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392/bin/bundle install"       
# end

rvm_shell "install thin" do
	ruby_string "ruby-1.9.3-p392@global"
	cwd "/vagrant_data/src/engineroom"
code %{
	thin install
}	
not_if { ::File.exists?("/etc/rc.d/thin") }
end
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

template "/etc/thin/engineroom.yml" do
  source "engineroom/engineroom.yml.erb"
  mode 00655
end

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

# execute 'make site available' do
  # command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.klostersford.com.au"
  # not_if do
    # File.exists?("/etc/nginx/sites-enabled/local.klostersford.com.au")
  # end   
# end

# execute 'make site available' do
  # command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.klostersvolkswagen.com.au"
  # not_if do
    # File.exists?("/etc/nginx/sites-enabled/local.klostersvolkswagen.com.au")
  # end   
# end

# execute 'make site available' do
  # command "sudo ln -s /etc/nginx/sites-available/local.klosters.com.au /etc/nginx/sites-enabled/local.lakevolkswagen.com.au"
  # not_if do
    # File.exists?("/etc/nginx/sites-enabled/local.lakevolkswagen.com.au")
  # end   
# end

# execute 'start up the thin web server' do
  # cwd "/vagrant_data/src/engineroom/"
  # command "/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin/bundle exec /etc/rc.d/thin start" 
  # not_if do
    # File.exists?("/vagrant_data/src/engineroom/tmp/pids/thin.3000.pid"  ) 
  # end
# end

rvm_shell "start up the thin web server" do
	ruby_string "ruby-1.9.3-p392@global"
	cwd "/vagrant_data/src/engineroom"
code %{
	bundle exec /etc/rc.d/thin start
}
not_if { ::File.exists?("/vagrant_data/src/engineroom/tmp/pids/thin.3000.pid") }
end

execute 'restart nginx' do
  command "sudo /etc/init.d/nginx restart"
end

