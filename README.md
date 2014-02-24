# trac

##Overview
Puppet module for managing trac instances

##Usage

### Creating a trac instance

To accept all defaults use this code.  **Note:** This will setup trac with no authentication and no admins.  You will need to setup your own apache auth at a more global level if you use these defaults.  You will also probably want to specify at least one admin using `trac::admin {'admin': }` in your manifest as well.
```puppet
  trac::project {'sampleproject': }
```

Setup using basic auth where this module manages the passwd file
```puppet
  trac::project {'sampleproject': 
   admins       => ['testadmin'],
   userhash     => {'testadmin'     => '4a7h9E5zdLJ/c',
                   {'testuser'      => '4a7h9E5zdLJ/c'}
```

Setup using basic auth where your module manages the passwd file
```puppet
  trac::project {'sampleproject': 
   admins       => ['testadmin'],
   auth_file    => '/etc/tracsecurity/passwd',
  }
```

Setup using your own template to manage the apache authentication

Manifest:
```puppet
  trac::project {'sampleproject':
    httpd_auth_content => template('mytracmodule/httpd/auth.erb'),
    admins     => ['testadmin'],
  }
```

mytracmodule/httpd/auth.erb:
```Ruby
  AuthType Kerberos
  AuthName "EXAMPLE"
  Krb5KeyTab /etc/httpd/keytabs/http.keytab
  KrbMethodNegotiate On
  KrbMethodK5Passwd On
  KrbVerifyKDC On
  KrbServiceName HTTP/trac.example.com
  require valid-user
```

### Parameters
#####`db_user` **Default:** testing

The database user who will manage the trac instance.  This is used to buid the connection string for the trac.ini file.

#####`db_host` **Default:** localhost

The host the database is running on.  This is used to buid the connection string for the trac.ini file.

#####`db_port` **Default:** 5432

The host the database is running on.  This is used to buid the connection string for the trac.ini file.

#####`httpd_auth_content` **Default:** Configures for basic auth

#####`auth_name` **Default:** trac

The name displayed in the BasicAuth authentication popup

#####`userhash` **Default:** undef

Hash of `{user => password}` where password is a hashed version that will be placed into the htpasswd file

#####`admins` **Deafult:** []

A list of usernames to give the TRAC_ADMIN permission to

#####`trac_title` **Default:** undef

The title of your project which will be displayed at the top of your trac page

#####`logo_image` **Default:** undef

A Puppet file URL that points to the image you want displayed on your trac page.  Ex. `puppet:///module/mytracmodule/images/logo.png`

#####`logo_height` **Default:** undef

The height of your logo

#####`logo_width` **Default:** undef

The width of your logo

#####`logo_alttext` **Default:** undef

Alt tag that will be associated with your logo


##TODOs
* Add support for other database backends (currently only supports postgresql)
* Abstract ini parameter management for the defined type trac::project and allow users to pass in a hash of override or additional parameters
