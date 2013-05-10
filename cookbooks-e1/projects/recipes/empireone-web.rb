#
# Cookbook Name:: application
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "php-mysql" do
  action :install
  notifies :restart, "service[apache2]"
end

if !!node['empireone-web']['db_setup'] == true
	
	gem_package "mysql" do
  		action :install
	end

	conn_info = { :host => node['empireone-web']['db_host'], :username => 'root', :password => node['mysql']['server_root_password'] }
	# query a database from a sql script on disk
	database 'empireone_com_au' do
		connection conn_info
		provider Chef::Provider::Database::Mysql
		action :create
	end

	database 'empireone_com_au' do
	  connection conn_info
		provider Chef::Provider::Database::Mysql
	  sql { ::File.open("#{node['empireone-web']['src_path']}/sql/db-dump.sql").read }
	  action :query
	end

end

web_app "empireone-web" do
	server_name node['empireone-web']['domain']
	server_aliases [ node['fqdn'] ]
	docroot "#{node['empireone-web']['src_path']}"

	# this specifies which cookbook includes the basic web_app.conf template
	# should a project require a more specific template, commenting this line
	# and creating the template in this 'project' cookbook should do, using:
	# template "projectname.conf.erb"
	cookbook "apache2"
end


template "#{node['empireone-web']['src_path']}/wp-config.php" do
  source "empireone-web/wp-config.php.erb"
  mode 00644
end