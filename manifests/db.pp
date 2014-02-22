define trac::db($db_user,
                $db_pass,
                $db_name) { 

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
}
