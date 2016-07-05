#
# Cookbook Name:: LAMP
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

%w(php-devel php-mbstring).each { |p| package p }

%w(httpd mysqld).each do |srv|
  service srv do
    supports status: true, restart: true, reload: true
    action [:enable, :start]
  end
end

user = 'ec2-user'
name = "#{node['LAMP']['group']['name']}"

group "#{name}" do
  action :create
  members "#{user}"
  append true
end

www = "#{node['LAMP']['www']}"

directory "#{www}" do
  recursive true
  mode '2775'
  owner "#{user}"
  group "#{name}"
  action :create
end

doc_root = "#{node['LAMP']['doc_root']}"

directory "#{doc_root}" do
  recursive true
  action :create
end

html = "#{node['LAMP']['doc_root']}index.html"

file "#{html}" do
  mode '0664'
  owner "#{user}"
  group "#{name}"
  action :nothing
end

httpd_conf = node['LAMP']['httpd_conf']

template "httpd_conf" do
  path "#{httpd_conf['dir']}#{httpd_conf['name']}"
  source "httpd_conf.erb"
  mode '0644'
end

template "php.ini" do
  path '/etc/php.ini'
  source "php.ini.erb"
  mode '0644'
end
