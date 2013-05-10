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

if !!node['empireone_web']['db_setup'] == true
	
	gem_package "mysql" do
  		action :install
	end

	conn_info = { :host => node['empireone_web']['db_host'], :username => 'root', :password => node['mysql']['server_root_password'] }
	# query a database from a sql script on disk
	database node['empireone_web']['db_name'] do
		connection conn_info
		provider Chef::Provider::Database::Mysql
		action :create
	end

	database node['empireone_web']['db_name'] do
	  connection conn_info
		provider Chef::Provider::Database::Mysql
	  sql { ::File.open("#{node['empireone_web']['src_path']}/sql/db-dump.sql").read }
	  action :query
	end

	database node['empireone_web']['db_name'] do
	  connection conn_info
		provider Chef::Provider::Database::Mysql
	  sql { "UPDATE #{node['empireone_web']['db_name']}.#{node['empireone_web']['db_prefix']}options set option_value = 'http://#{node['empireone_web']['domain']}' WHERE option_name in ('home','siteurl')" }
	  #sql { "SELECT 1" }
	  action :query
	end

end

web_app node['empireone_web']['db_name'], :directory_options => "FileInfo" do
	server_name node['empireone_web']['domain']
	server_aliases [ node['fqdn'] ]
	docroot "#{node['empireone_web']['src_path']}"

	# this specifies which cookbook includes the basic web_app.conf template
	# should a project require a more specific template, commenting this line
	# and creating the template in this 'project' cookbook should do, using:
	# template "projectname.conf.erb"
	cookbook "apache2"
end


template "#{node['empireone_web']['src_path']}/wp-config.php" do
  source "empireone_web/wp-config.php.erb"
  mode 00644
end