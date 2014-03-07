require 'spec_helper'

describe 'trac::project' do
  let(:title) { 'sampleproject' }
  let(:pre_condition) { "include 'apache'" }
  trac_env = '/var/opt/trac_instances/sampleproject'
  trac_db_define = 'trac_db_sampleproject'

  it { should contain_class('trac') }
  it { should contain_trac__db(trac_db_define) }
  it { should contain_exec('init_trac_sampleproject').with( {'require' => "Trac::Db[#{trac_db_define}]" } ) }

  context "userhash => {'testuser' => 'hashedpass'}" do
    let(:params) { { :userhash => { 'testuser' => 'hashedpass' } } }
    it { should contain_file("#{trac_env}/passwd").with( { 'content' => "testuser:hashedpass\n" } ) }
  end

  context "admins => ['testadmin']" do
    let(:params) { { :admins => ['testadmin'] } }
    it { should contain_trac__adminloop('testadmin') }
  end

end
