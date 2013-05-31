
include_recipe "java"

case node["platform"]
when "centos","redhat","fedora"
  include_recipe "jpackage"
end

jetty_pkgs = value_for_platform(
  ["debian","ubuntu"] => {
    "default" => ["jetty","libjetty-extra"]
  },
  ["centos","redhat","fedora"] => {
    "default" => ["jetty6","jetty6-jsp-2.1","jetty6-management"]
  },
  "default" => ["jetty"]
)
jetty_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

service "jetty" do
  case node["platform"]
  when "centos","redhat","fedora"
    service_name "jetty6"
    supports :restart => true
  when "debian","ubuntu"
    service_name "jetty"
    supports :restart => true, :status => true
    action [:enable, :start]
  end
end

template "/etc/default/jetty" do
  source "jetty/default_jetty.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "jetty"), :delayed
end

template "/etc/jetty6/jetty.xml" do
  source "jetty/jetty.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "jetty"), :delayed
end
