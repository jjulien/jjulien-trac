# Due to limitations in the Puppet DSL this adminloop will
# only work if no duplicate admin lists are used for more than one
# trac::project instance.  So for example, the following would cause a conflict:
#
# trac::project {'project1': admins => ['user1', 'user2']}
# trac::project {'project2': admins => ['user1', 'user2']}
#
# if any of the admins were different between these projects the conflict would
# not exist.  The future parser in 3.2 will resolve this with the each method 
# being added to arrays
#

define trac::adminloop($trac_env) {
  trac::admin {"${name}_${trac_env}":
    user     => $name,
    trac_env => $trac_env,
  }
}

define trac::project($db_user='trac_user',
                     $db_pass='testing',
                     $db_host='localhost',
                     $db_port='5432',
                     $auth_name='trac',
                     $auth_file=undef,
                     $userhash=undef,
                     $admins=[],
                     $trac_title=undef,
                     $logo_image=undef,
                     $logo_height=undef,
                     $logo_width=undef,
                     $logo_alttext=undef,
                     $webuser='apache',
                     $webgroup='apache') {

  require('trac')

  $db_name = "trac_${name}"
  $db_url = "postgres://${db_user}:${db_pass}@${db_host}:${db_port}/${db_name}?schema=trac"
  $trac_env = "${trac::project_path}/$name"
  $trac_config = "${trac::project_path}/${name}/conf/trac.ini"
  $trac_augeas_context = "/files${trac_config}"
  $wsgi_script = "${trac::wsgidir}/${name}.wsgi"  
  
  if ( ! $auth_file ) { 
    $real_auth_file = "${trac_env}/passwd"
  } else { $real_auth_file = $auth_file }
  if ( ! $trac_title ) { 
    $project_name = $name
  } else { $project_name = $trac_title }

  if ( $userhash ) { 
    file {$real_auth_file:
       ensure  => file,
       owner   => $webuser,
       group   => $webgroup,
       mode    => 0400,
       content => template('trac/passwd.erb'),
       require => Exec["init_trac_${name}"],
    } 
  }

  trac::adminloop{$admins:
       trac_env   => $trac_env,
       require    => Exec["init_trac_${name}"],
  }

  include 'postgresql::server'
  
  postgresql::server::db {$db_name: 
     user     => $db_user,
     password => postgresql_password($db_user, $db_pass),
  }
  if ( ! defined(Postgresql::Server::Role[$db_user])) {
    postgresql::server::role {$db_user:
      password_hash => postgresql_password($db_user, $db_pass)
    }
  }
  exec {"init_trac_${name}":
     command => "/usr/bin/trac-admin ${trac_env} initenv '${project_name}' '$db_url'",
     unless => "/usr/bin/test -d ${trac_env}",
     require => Postgresql::Server::Db[$db_name],
  }

  exec {"create_trac_webdocs_${name}":
     command => "/usr/bin/trac-admin $trac_env deploy ${trac::webdir}",
     unless  => "/usr/bin/test -d ${trac::webdir}/htdocs",
  }

  exec {"trac_webdocs_ownership_${name}":
     command     => "/bin/chown -R apache:apache ${trac_env}",
     refreshonly => true,
     subscribe   => Exec["init_trac_${name}"],
  }

  file {"/etc/httpd/conf.d/trac_${name}.conf":
     ensure  => file,
     owner   => $webuser,
     group   => $webgroup,
     content => template('trac/httpd/project.conf.erb'),
     notify  => Service['httpd'],
  }

  file {"${trac_env}/htdocs/images":
     ensure => directory,
     owner  => $webuser,
     group  => $webgroup,
     mode   => 0755,
     require => Exec["init_trac_${name}"],
  }
  file {"${wsgi_script}":
     ensure => file,
     owner  => $webuser,
     group  => $webgroup,
     content => template('trac/wsgi.erb'),
     notify  => Service['httpd'],
  }

  #TODO: Break out the ini config into one big hash of hash where the first hash key is section and the 
  #      embedded hash key is the parameter => value.  This might be better accomplished by using a 
  #      template, but then there is the compatability of trac config versions to worry about.  Using
  #      augeas pretty well ensures the necessary default trac config items that come with the RPM are intact.
  if ( $logo_image ) { 
     file {"${trac_env}/htdocs/images/${name}_logo.png":
        ensure => file,
        owner  => $webuser,
        group  => $webgroup,
        mode   => 0644,
        source => $logo_image,
        require => File["${trac_env}/htdocs/images"],
     }
     augeas{"trac_logo_${name}":
        incl    => $trac_config,
        changes => ["set header_logo/src 'site/images/${name}_logo.png'"],
        lens    => "Puppet.lns",
        require => Exec["init_trac_${name}"],
     }
     if ( $logo_width ) { 
       augeas {"trac_logo_width":
         incl    => $trac_config,
         changes => ["set header_logo/width $logo_width"],
         lens    => "Puppet.lns",
        require => Exec["init_trac_${name}"],
       }
     }
     if ( $logo_height ) { 
       augeas {"trac_logo_height":
         incl    => $trac_config,
         changes => ["set header_logo/height $logo_height"],
         lens    => "Puppet.lns",
        require => Exec["init_trac_${name}"],
       }
     }
     if ( $logo_alttext ) { 
       augeas {"trac_logo_alttext":
         incl    => $trac_config,
         changes => ["set header_logo/alt '$logo_alttext'"],
         lens    => "Puppet.lns",
        require => Exec["init_trac_${name}"],
       }
     }
  } 

  augeas{"trac_basicsettings_${name}":
     incl    => $trac_config,
     changes => ["set project/name '$project_name'",
                 "set trac/database '$db_url'"],
     lens    => "Puppet.lns",
     require => Exec["init_trac_${name}"],
  }
}