class {'apache':
   purge_configs => false,
}

trac::project {'sampletrac': 
   trac_title   => 'SamplePuppet Trac',
   auth_name    => 'SamplePuppetTrac',
   admins       => ['testuser'],
   userhash     => {'testuser'     => '4a7h9E5zdLJ/c'}  # Password is testpass
}
