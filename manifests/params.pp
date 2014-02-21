class trac::params {
  $project_path = '/var/opt/trac_instances'
  $package      = 'trac10'
  $webdir       = '/var/trac'
  $wsgidir      = "${webdir}/wsgi"
  $web_config   = '/etc/httpd/conf.d/01-trac.conf'
  $webuser      = 'apache'
  $webgroup     = 'apache'
}
