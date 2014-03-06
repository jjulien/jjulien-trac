class trac($project_path=$trac::params::project_path,
           $trac_package=$trac::params::package,
           $webdir=$trac::params::webdir,
           $wsgidir=$trac::params::wsgidir,
           $web_config=$trac::params::web_config,
           $webuser=$trac::params::webuser,
           $webgroup=$trac::params::webgroup,
           $manage_apache=false) inherits trac::params {

  if ( $manage_apache ) {
     include 'apache'
  }

  package {$trac_package:
    ensure => installed,
  }
  
  if ( ! defined(Package['python-psycopg2']) ) { 
    package {'python-psycopg2':
      ensure => installed,
    }
  }
  if ( ! defined(Apache::Mod['wsgi'])) { 
    apache::mod {'wsgi': }
  }
  if ( ! defined(Apache::Mod['auth_basic'])) { 
    apache::mod {'auth_basic': }
  }
  if ( ! defined(Apache::Mod['authn_file'])) { 
    apache::mod {'authn_file': }
  }
  if ( ! defined(Apache::Mod['authz_user'])) { 
    apache::mod {'authz_user': }
  }
  if ( ! defined(Apache::Mod['authz_default'])) { 
    apache::mod {'authz_default': }
  }
  file {$project_path:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0755, 
  }  
  file {[$webdir, $wsgidir]:
    ensure => directory,
    owner   => $webuser,
    group  => $webgroup,
    mode   => 0755,
  }
  file {$web_config:
    ensure => file,
    owner  => $webuser,
    group  => $webgroup,
    mode   => 0644,
    content => template('trac/httpd/trac.conf.erb'),
  }
}
