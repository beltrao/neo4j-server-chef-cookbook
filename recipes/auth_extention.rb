require "tmpdir"
require 'uri'

bag = search('neo4j-server').first
neo4j_admin = bag.to_hash['admin']
neo4j_users = bag.to_hash['users']

jar_name    = "authentication-extension-#{node.neo4j.server.plugins.auth.version}.jar"
jar_url     = "http://dist.neo4j.org/authentication-extension/#{jar_name}"
plugins_dir = File.join(node.neo4j.server.installation_dir, 'plugins')
properties_file = File.join(node.neo4j.server.conf_dir, 'neo4j-server.properties')

remote_file "#{plugins_dir}/authentication-extension.jar" do
  owner  node.neo4j.server.user
  group  node.neo4j.server.group
  source jar_url
end

config_data_lines = [
  "# Basic Authentication for webadmin interface",
  "org.neo4j.server.credentials=#{neo4j_admin['username']}:#{neo4j_admin['password']}",
  "org.neo4j.server.thirdparty_jaxrs_classes=org.neo4j.server.extension.auth=/auth"
]

ruby_block "add auth config lines to #{properties_file}" do
  block do
    config_data_lines.each do |line|
      line_start_regex = /#{line.split('=').first}/

      # Rewrite it if you can make it work every time.
      fe = Chef::Util::FileEdit.new(properties_file)
      fe.search_file_delete_line(line_start_regex)
      fe.write_file

      fe = Chef::Util::FileEdit.new(properties_file)
      fe.insert_line_if_no_match(line_start_regex, line)
      fe.write_file
    end
  end
  notifies :restart, 'service[neo4j]', :immediately
end

url = URI::Generic.build(
        :scheme => (node.neo4j.server.https.enabled ? 'https' : 'http'),
        :host   => '127.0.0.1',
        :port   => (node.neo4j.server.https.enabled ? node.neo4j.server.https.port : node.neo4j.server.http.port),
        :path   => '/auth/add-user-rw'
      ).to_s

neo4j_users.each do |user|
  bash "add #{user['username']} to list of users" do
    code <<-EOS
      curl -k --user #{neo4j_admin['username']}:#{neo4j_admin['password']} \\
        -d "user=#{user['username']}:#{user['password']}"               \\
        #{url}
    EOS
  end
end
