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

if !!node['blueplains']['db_setup'] == true
	
	# chef uses the mysql gem to run commands
	gem_package "mysql" do
  	action :install
	end

	conn_info = { :host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password'] }

	# query a database from a sql script on disk
	database 'mahlab_blueplains' do
		connection conn_info
		provider Chef::Provider::Database::Mysql
		action :create
	end

	database 'mahlab_blueplains' do
	  connection conn_info
		provider Chef::Provider::Database::Mysql
	  sql { ::File.open("#{node['blueplains']['src_path']}/sql/db-model.sql").read }
	  action :query
	end

		database 'mahlab_blueplains' do
	  connection conn_info
		provider Chef::Provider::Database::Mysql
	  sql { ::File.open("#{node['blueplains']['src_path']}/sql/db-data.sql").read }
	  action :query
	end

end

web_app "insuranceandrisk" do
	server_name node['blueplains']['irp_domain']
	server_aliases [ node['fqdn'] ]
	docroot "#{node['blueplains']['src_path']}/#{node['blueplains']['irp_docroot']}"
  	allow_override "FileInfo"
	# this specifies which cookbook includes the basic web_app.conf template
	# should a project require a more specific template, commenting this line
	# and creating the template in this 'project' cookbook should do, using:
	# template "projectname.conf.erb"
	cookbook "apache2"
end


web_app "probus" do
	server_name node['blueplains']['pb_domain']
	server_aliases [ node['fqdn'] ]
	docroot "#{node['blueplains']['src_path']}/#{node['blueplains']['pb_docroot']}"
  	allow_override "FileInfo"
	# this specifies which cookbook includes the basic web_app.conf template
	# should a project require a more specific template, commenting this line
	# and creating the template in this 'project' cookbook should do, using:
	# template "projectname.conf.erb"
	cookbook "apache2"
end


web_app "blueplains-cms" do
	server_name node['blueplains']['cms_domain']
	server_aliases [ node['fqdn'] ]
	docroot "#{node['blueplains']['src_path']}/#{node['blueplains']['cms_docroot']}"
  	allow_override "FileInfo"
	# this specifies which cookbook includes the basic web_app.conf template
	# should a project require a more specific template, commenting this line
	# and creating the template in this 'project' cookbook should do, using:
	# template "projectname.conf.erb"
	cookbook "apache2"
end


web_app "blueplains-microsite" do
	server_name node['blueplains']['microsite_domain']
	server_aliases [ node['fqdn'] ]
	docroot "#{node['blueplains']['src_path']}/#{node['blueplains']['microsite_docroot']}"
  	allow_override "FileInfo"
  
	# this specifies which cookbook includes the basic web_app.conf template
	# should a project require a more specific template, commenting this line
	# and creating the template in this 'project' cookbook should do, using:
	# template "projectname.conf.erb"
	cookbook "apache2"
end


template "#{node['blueplains']['src_path']}/app-public/config/core.php" do
  source "blueplains/app-public/config/core.php.erb"
  mode 00644
end
template "#{node['blueplains']['src_path']}/app-private/config/core.php" do
  source "blueplains/app-private/config/core.php.erb"
  mode 00644
end
template "#{node['blueplains']['src_path']}/app-microsite/config/core.php" do
  source "blueplains/app-microsite/config/core.php.erb"
  mode 00644
end