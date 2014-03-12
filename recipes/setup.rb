# 6. Install config files
template "#{node.neo4j.server.conf_dir}/neo4j-server.properties" do
  source "neo4j-server.properties.erb"
  owner node.neo4j.server.user
  mode  0644
  notifies :restart, 'service[neo4j]'
end

template "#{node.neo4j.server.conf_dir}/neo4j-wrapper.conf" do
  source "neo4j-wrapper.conf.erb"
  owner node.neo4j.server.user
  mode  0644
  notifies :restart, 'service[neo4j]'
end

template "#{node.neo4j.server.conf_dir}/neo4j.properties" do
  source "neo4j.properties.erb"
  owner node.neo4j.server.user
  mode 0644
  notifies :restart, 'service[neo4j]'
end
