# frozen_string_literal: true

require './spec_helper'

init_conf

aem_base = @hiera.lookup('publish::aem_base', nil, @scope)
aem_base ||= '/opt'

aem_port = @hiera.lookup('publish::aem_port', nil, @scope)
aem_port ||= '4503'

aem_publish_volume_mount_point = @hiera.lookup('aem_curator::install_author::repository_volume_mount_point', nil, @scope)
aem_publish_volume_mount_point ||= '/mnt/ebs1'

aem_publish_volume_device = @hiera.lookup('aem_curator::install_publish::repository_volume_device', nil, @scope)
aem_publish_volume_device ||= '/dev/xvdb'

# aem_keystore_password = @hiera.lookup('aem_curator::install_publish::aem_keystore_password', nil, @scope)

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

describe file("#{aem_base}/aem/publish/crx-quickstart/repository") do
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
