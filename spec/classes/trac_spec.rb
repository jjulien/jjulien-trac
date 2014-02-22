require 'spec_helper'

describe 'trac' do
   let(:pre_condition) {
     "  class apache {} 
        define apache::mod() {} "
   }
   it { should contain_class('apache') }
   puts :webuser
   context "with trac_package => trac" do
     let(:params) { {:trac_package => 'trac' } }
     it { should contain_package('trac') }
   end 

   context "with project_path => /var/opt/trac" do
     let (:params) { {:project_path => '/var/opt/trac' } }
     it { should contain_file('/var/opt/trac').with({
       'ensure' => 'directory',
     }) }
   end

   context "with webuser and webgroup set" do
     web_config = '/etc/httpd/conf.d/01-trac.conf'
     let (:params) { {
        :web_config => web_config,
        :webuser    => 'customuser',
        :webgroup   => 'customgroup'
     } }
     it { should contain_file(web_config).with({
        'owner' => 'customuser',
        'group' => 'customgroup'
     }) }
  end
end
