# frozen_string_literal: true

require './spec_helper'

init_conf

aem_base = @hiera.lookup('author::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('author::aem_port', nil, @scope)
aem_port ||= '4502'

aem_author_volume_mount_point = @hiera.lookup('aem_curator::install_author::repository_volume_mount_point', nil, @scope)
aem_author_volume_mount_point ||= '/mnt/ebs1'

aem_author_volume_device = @hiera.lookup('aem_curator::install_author::repository_volume_device', nil, @scope)
aem_author_volume_device ||= '/dev/xvdb'

# aem_keystore_password = @hiera.lookup('aem_curator::install_author::aem_keystore_password', nil, @scope)

describe group('aem-author') do
  it { should exist }
end

describe user('aem-author') do
  it { should exist }
  its('group') { should eq 'aem-author' }
end

describe group('aem-publish') do
  it { should exist }
end

describe user('aem-publish') do
  it { should exist }
  its('group') { should eq 'aem-publish' }
end

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file("#{aem_base}/aem/author") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe file("#{aem_base}/aem/author/license.properties") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00440' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe file("#{aem_base}/aem/author/aem-author-#{aem_port}.jar") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-author' }
  it { should be_grouped_into 'aem-author' }
end

describe etc_fstab.where { device_name == aem_author_volume_device } do
  its('mount_point') { should cmp aem_author_volume_mount_point }
end

describe file("#{aem_base}/aem/author/crx-quickstart/repository") do
  its('type') { should eq :symlink }
  its('link_path') { should eq aem_author_volume_mount_point }
  its('owner') { should eq 'aem-author' }
  its('group') { should eq 'aem-author' }
end

describe service('aem-author') do
  it { should_not be_enabled }
  it { should_not be_running }
end

# describe command("keytool -list -keystore #{aem_base}/aem/author/crx-quickstart/ssl/aem.ks -alias cqse -storepass #{aem_keystore_password}") do
#   its('exit_status') { should eq 0 }
# end

# describe file("#{aem_base}/aem/author/crx-quickstart/conf/cq.pid") do
#   it { should_not exist }
# end

describe file('/etc/puppetlabs/puppet/author.yaml') do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00644' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

aem_base = @hiera.lookup('publish::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('publish::aem_port', nil, @scope)
aem_port ||= '4503'

aem_publish_volume_mount_point = @hiera.lookup('aem_curator::install_publish::repository_volume_mount_point', nil, @scope)
aem_publish_volume_mount_point ||= '/mnt/ebs2'

aem_publish_volume_device = @hiera.lookup('aem_curator::install_publish::repository_volume_device', nil, @scope)
aem_publish_volume_device ||= '/dev/xvdc'


# aem_keystore_password = @hiera.lookup('aem_curator::install_publish::aem_keystore_password', nil, @scope)

describe file("#{aem_base}/aem") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file("#{aem_base}/aem/publish") do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe file("#{aem_base}/aem/publish/license.properties") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00440' }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe file("#{aem_base}/aem/publish/aem-publish-#{aem_port}.jar") do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00775' }
  it { should be_owned_by 'aem-publish' }
  it { should be_grouped_into 'aem-publish' }
end

describe etc_fstab.where { device_name == aem_publish_volume_device } do
  its('mount_point') { should cmp aem_publish_volume_mount_point }
end

describe file('/opt/aem/publish/crx-quickstart/repository') do
  its('type') { should eq :symlink }
  its('link_path') { should eq aem_publish_volume_mount_point }
  its('owner') { should eq 'aem-publish' }
  its('group') { should eq 'aem-publish' }
end

describe service('aem-publish') do
  it { should_not be_enabled }
  it { should_not be_running }
end

# describe command("keytool -list -keystore #{aem_base}/aem/publish/crx-quickstart/ssl/aem.ks -alias cqse -storepass #{aem_keystore_password}") do
#   its('exit_status') { should eq 0 }
# end

# describe file("#{aem_base}/aem/publish/crx-quickstart/conf/cq.pid") do
#   it { should_not exist }
# end

describe file('/etc/puppetlabs/puppet/publish.yaml') do
  it { should be_file }
  it { should exist }
  its('mode') { should cmp '00644' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

apache_package = @hiera.lookup('apache::apache_name', nil, @scope)
apache_package ||= 'httpd'

apache_http_port = @hiera.lookup('aem_curator::install_dispatcher::apache_http_port', nil, @scope)
apache_https_port = @hiera.lookup('aem_curator::install_dispatcher::apache_https_port', nil, @scope)

cert_filename = @hiera.lookup('aem_curator::install_dispatcher::cert_filename', nil, @scope)

describe package(apache_package) do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled }
  # it { should be_running }
end

describe port(apache_http_port) do
  it { should be_listening }
end

describe port(apache_https_port) do
  it { should be_listening }
end

describe file(cert_filename) do
  it { should be_file }
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '00600' }
  its('size') { should be > 0 }
end
