#require 'rspec-puppet'
require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.default_facts = {
    :osfamily               => "RedHat",
    :operatingsystem        => "CentOS",
    :operatingsystemrelease => "6.4",
    :concat_basedir         => "/tmp/concat",
  }
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
