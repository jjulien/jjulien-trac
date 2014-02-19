define trac::admin($user=$name, $trac_env) {
  exec{"trac_admin_${user}_${trac_env}":
    command => "/usr/bin/trac-admin ${trac_env} permission add ${user} TRAC_ADMIN",
    unless  => "/usr/bin/trac-admin ${trac_env} permission list ${user}|grep -q '^${user}  TRAC_ADMIN'",
  }
}
