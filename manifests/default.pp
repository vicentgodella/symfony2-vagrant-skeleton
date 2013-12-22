exec { 'disable-swap':
  path    => '/sbin',
  command => 'swapoff -a',
  user    => 'root',
} ->
file { '/etc/resolv.conf' :
  content => 'nameserver 8.8.8.8',
} ->
exec { 'apt-get update':
  command => 'apt-get update',
  path    => '/usr/bin/',
  timeout => 0,
  tries   => 3,
}

class { 'apt':
  always_apt_update => true,
}

package { ['python-software-properties']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

file { '/home/vagrant/.bash_aliases':
  ensure => 'present',
  source => 'puppet:///modules/puphpet/dot/.bash_aliases',
}

package { ['build-essential', 'vim', 'curl', 'git', 'git-core', 'ant']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

class { 'apache': }

apache::dotconf { 'custom':
  content => 'EnableSendfile Off',
}
file { '/etc/apache2/sites-enabled/000-default.conf':
  ensure => absent,
  notify => Service['apache2']
}

apache::module { 'rewrite': }

apache::vhost { 'sf2-vagrant.dev':
  server_name   => 'sf2-vagrant.dev',
  serveraliases => [],
  docroot       => '/var/www/web',
  port          => '80',
  env_variables => [],
  priority      => '20',
}

apt::ppa { 'ppa:ondrej/php5':
  before  => Class['php'],
}

class { 'php':
  service => 'apache',
  require => Package['apache'],
}

php::module { 'php5-mysql': }
php::module { 'php5-cli': }
php::module { 'php5-curl': }
php::module { 'php5-intl': }
php::module { 'php5-mcrypt': }
php::module { 'php-apc': }

class { 'php::devel':
  require => Class['php'],
}

class { 'php::pear':
  require => Class['php'],
}


#php::pecl::module { 'APC':
#  use_package => false,
#}
#
#class { 'xdebug':
#  service => 'apache',
#}
#
#xdebug::config { 'cgi':
#  remote_autostart => '0',
#  remote_port      => '9000',
#}
#xdebug::config { 'cli':
#  remote_autostart => '0',
#  remote_port      => '9000',
#}



class { 'php::composer': }

php::ini { 'php':
  value   => ['date.timezone = "Europe/Madrid"'],
  target  => 'php.ini',
  service => 'apache',
}

class { 'mysql':
  root_password => 'sf2-vagrant',
  require       => Exec['apt-get update'],
}

mysql::grant { 'sf2-vagrant':
  mysql_privileges     => 'ALL',
  mysql_db             => 'sf2-vagrant',
  mysql_user           => 'sf2-vagrant',
  mysql_password       => 'sf2-vagrant',
  mysql_host           => 'localhost',
  mysql_grant_filepath => '/home/vagrant/puppet-mysql',
}

class { 'phpmyadmin':
  require => Class['mysql'],
}

apache::vhost { 'phpmyadmin':
  server_name => 'phpmyadmin',
  docroot     => '/usr/share/phpmyadmin',
  port        => 80,
  priority    => '10',
  require     => Class['phpmyadmin'],
}

file {'/etc/apache2/conf-enabled/phpmyadmin.conf':
  ensure => link,
  target => '/etc/phpmyadmin/apache.conf',
  require     => [ Class['phpmyadmin'], Class['apache']]
}
