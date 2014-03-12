#
# Cookbook Name:: neo4j-server
# Recipe:: server_debian
# Copyright 2014, Denis Yagofarov <di@aejis.eu>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

node.default[:neo4j][:server][:data_dir]  = "data/graph.db"
node.default[:neo4j][:server][:conf_dir]  = "/etc/neo4j"
node.default[:neo4j][:server][:lock_path] = "../data/#{node[:neo4j][:server][:name]}.lock"
node.default[:neo4j][:server][:pid_path]  = "../data/#{node[:neo4j][:server][:name]}.pid"

include_recipe "neo4j-server::apt_repository"

package "neo4j"

service "neo4j" do
  service_name 'neo4j-service'
  supports :start => true, :stop => true, :restart => true
end

include_recipe "neo4j-server::setup"
