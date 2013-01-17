class build {

  package {'git': 
    ensure => present,
  }

  package {'scons': 
    ensure => present,
  }
  package {'gcc-c++': 
    ensure => present,
  }
  package {'glibc-devel': 
    ensure => present,
  }

}

class desktop {
  package {'xorg-x11-apps':
    ensure => present,
  }
}

# node 'ip-10-170-255-82.us-west-1.compute.internal' {
      
      # Note the quotes around the name! Node names can have characters that
      # aren't legal for class names, so you can't always use bare, unquoted
      # strings like we do with classes.
      
      # Any resource or class declaration can go inside here. For now:
      
      # include apache
      
      # class {'ntp': 
        # enable => false,
        # ensure => stopped,
      # }
# }

node 'eahdell15.crackerpad.net' {
  class { 'build': }
  class { 'desktop': }
}

node 'default' {
}

#file {'/tmp/templated.txt':
  #ensure => present,
  #content => template('ernie/templated.erb'),
#}

file {'/etc/sudoers.d/wheel':
  path    => '/etc/sudoers.d/wheel',
  ensure  => present,
  mode    => 0440,
  owner   => 'root',
  group   => 'root',
  source  => 'puppet:///modules/ernie/etc/sudoers.d/wheel',
}	


file {'/etc/yum.repos.d/10gen.repo':
  path    => '/etc/yum.repos.d/10gen.repo',
  ensure  => present,
  mode    => 0644,
  owner   => 'root',
  group   => 'root',
  source  => 'puppet:///modules/ernie/etc/yum.repos.d/10gen.repo',
}	

package {'sudo':
  ensure => present,
  subscribe => File['/etc/sudoers.d/wheel'],
}

package {'man':
  ensure => present,
}

package {'wget':
  ensure => present,
}



package {'vim-enhanced':
  ensure => present,
}

package {'python-setuptools':
  ensure => present,
}
exec { "install pip": 
  command => "easy_install pip",
  path => "/usr/bin",
  require => Package['python-setuptools'],
}

package {'pymongo':
  ensure => present,
  provider => pip,
  require => Exec['install pip'],
}


package {'mongo-10gen-server': 
  ensure => present,
  subscribe => File['/etc/yum.repos.d/10gen.repo'],
}
package {'mongo-10gen': 
  ensure => present,
  subscribe => File['/etc/yum.repos.d/10gen.repo'],
}

#file {'/etc/yum/yum-updatesd.conf':
  #path    => '/etc/yum/yum-updatesd.conf',
  #ensure  => present,
  #mode    => 0644,
  #owner   => 'root',
  #group   => 'root',
  #source  => 'puppet:///modules/ernie/etc/yum/yum-updatesd.conf',
#}

file {'/etc/mongod.conf':
  path    => '/etc/mongod.conf',
  ensure  => present,
  mode    => 0644,
  content  => template('ernie/etc/mongod.conf'),
#'puppet:///modules/ernie/etc/mongod.conf',
}


file {'/etc/mongodb.key':
  path    => '/etc/mongodb.key',
  ensure  => present,
  mode    => 0600,
  owner   => 'mongod',
  source  => 'puppet:///modules/ernie/etc/mongodb.key',
}


package {'telnet': ensure => present }

package {'mlocate': ensure => present }

#package {'yum-updatesd': ensure => present }

package {'yum-cron': ensure => present }
package {'screen': ensure => present }

#service {'yum-updatesd': 
  #ensure => running,
  #enable => true,
  #subscribe => File['/etc/yum/yum-updatesd.conf'],
#}

service {'mongod': 
  ensure => running,
  enable => true,
  subscribe => File['/etc/mongod.conf'],
}


service {'yum-cron': 
  ensure => running,
  enable => true,
}


group { 'ernie':
  ensure => 'present',
  gid    => '501',
}

user { 'ernie':
  ensure => 'present',
  gid    => '501',
  groups => ['wheel'],
  home   => '/home/ernie',
  managehome => true,
  shell  => '/bin/bash',
  uid    => '500',
}
file { '/home/ernie':
  ensure => 'directory',
  group  => '501',
  mode   => '700',
  owner  => '500',
}
file { '/home/ernie/.ssh':
  ensure => 'directory',
  group  => '501',
  mode   => '700',
  owner  => '500',
}

file {'/home/ernie/.ssh/authorized_keys':
  path    => '/home/ernie/.ssh/authorized_keys',
  ensure  => present,
  mode    => 0600,
  owner   => 'ernie',
  source  => 'puppet:///modules/ernie/home/ernie/.ssh/authorized_keys',
}
file { '/etc/aliases':
  ensure  => present,
  group   => '0',
  mode    => '644',
  owner   => '0',
  source  => 'puppet:///modules/ernie/etc/aliases',
}

exec { "new_aliases":
  command => "/usr/bin/newaliases",
  alias => "create aliases db",
  subscribe => File["/etc/aliases"],
  refreshonly => true,
}
