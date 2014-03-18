wrapper_file = File.join(node.neo4j.server.conf_dir, 'neo4j-wrapper.properties')
newrelic_dir = File.join(node.neo4j.server.installation_dir, 'newrelic')

agent_jar_name    = "newrelic-agent-#{node.neo4j.newrelic.agent_version}.jar"
agent_jar_url     = "http://download.newrelic.com/newrelic/java-agent/newrelic-agent/#{node.neo4j.newrelic.agent_version}/#{agent_jar_name}"
agent_jar_path    = File.join(newrelic_dir, agent_jar_name)
agent_config_path = File.join(node.neo4j.server.conf_dir, 'newrelic.yml')

directory newrelic_dir do
  owner  node.neo4j.server.user
  group  node.neo4j.server.group
  mode   00644
end

remote_file agent_jar_path do
  owner  node.neo4j.server.user
  group  node.neo4j.server.group
  source agent_jar_url
end

template agent_config_path do
  owner  node.neo4j.server.user
  group  node.neo4j.server.group
  source 'newrelic.yml.erb'
end

config_data_lines = [
  "# NewRelic Java Agent",
  "wrapper.java.additional.9998=-Dnewrelic.config.file=#{agent_config_path}",
  "wrapper.java.additional.9999=-javaagent:#{agent_jar_path}"
]

ruby_block "add NewRelic startup lines to #{wrapper_file}" do
  block do
    config_data_lines.each do |line|
      line_start_regex = /#{line.split('=').first}/

      # Rewrite it if you can make it work every time.
      fe = Chef::Util::FileEdit.new(wrapper_file)
      fe.search_file_delete_line(line_start_regex)
      fe.write_file

      fe = Chef::Util::FileEdit.new(wrapper_file)
      fe.insert_line_if_no_match(line_start_regex, line)
      fe.write_file
    end
  end
  notifies :restart, 'service[neo4j]', :immediately
end
