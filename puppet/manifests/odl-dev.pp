#vcsrepo {'/home/vagrant/devstack':
#    ensure   => present,
#    provider => git,
#    user     => 'vagrant',
#    source   => 'https://github.com/openstack-dev/devstack.git',
#    # source   => 'https://github.com/flavio-fernandes/devstack.git',
#    # revision => 'odlDevel',
#    before   => File['/home/vagrant/devstack/local.conf'],
#}
#
#$hosts = hiera('hosts')
#

##
## Java
##
$java_version = "7"

# Default to requiring all packages be installed
Package {
	ensure => installed,
}
# Install Java, based on set $java_version (passed to Puppet in VagrantFile)
package { "java":
	name => "openjdk-${java_version}-jdk", # Install OpenJDK package (as Oracle JDK tends to require a more complex manual download & unzip)
}
# Set Java defaults to point at our Java package
# NOTE: $architecture is a "fact" automatically set by Puppet's 'facter'.
exec { "Update alternatives to Java ${jdk_version}":
	command => "update-java-alternatives --set java-1.${java_version}.0-openjdk-${architecture}",
					unless => "test \$(readlink /etc/alternatives/java) = '/usr/lib/jvm/java-${java_version}-openjdk-${architecture}/jre/bin/java'",
					require => [Package["java"], Package["maven"]], #Class['maven::maven'] # Run *after* Maven is installed, since Maven install sometimes changes the java alternative!
						path => "/usr/bin:/usr/sbin:/bin",
}

##
## Install Maven & Ant
##
package { "maven":
	require => Package["java"],
}
package { "ant":
	require => Package["java"],
}
# Install Git
package { "git":
}

# Check if our SSH connection to GitHub works. This verifies that SSH forwarding is working right.
#exec { "Verify SSH connection to GitHub works?" :
#	command => "ssh -T -oStrictHostKeyChecking=no git@github.com",
#					returns => 1, # If this succeeds, it actually returns '1'. If it fails, it returns '255'
#}

##
## Maven setup with https://forge.puppetlabs.com/maestrodev/maven
##
#$central = {
#  id => "myrepo",
#  username => "myuser",
#  password => "mypassword",
#  url => "http://repo.acme.com",
#  mirrorof => "external:*",      # if you want to use the repo as a mirror, see maven::settings below
#}
# $proxy = {
#  active => true, #Defaults to true
#  protocol => 'http', #Defaults to 'http'
#  host => 'http://proxy.acme.com',
#  username => 'myuser', #Optional if proxy does not require
#  password => 'mypassword', #Optional if proxy does not require
#  nonProxyHosts => 'www.acme.com', #Optional, provides exceptions to the proxy
#}
# Install Maven
#class { "maven::maven":
#	version => "3.0.5", # version to install
#	manage_symlink => false,
#	system_package => true,
#	symlink_target => false,
## you can get Maven tarball from a Maven repository instead than from Apache servers, optionally with a user/password
#		repo => {
##url => "http://repo.maven.apache.org/maven2",
##username => "",
#    #password => "",
#  }
#} ->
# # Setup a .mavenrc file for the specified user
#maven::environment { 'maven-env' : 
#    user => 'vagrant',
#    # anything to add to MAVEN_OPTS in ~/.mavenrc
#    maven_opts => '-Xmx1024m -Xms512m',       # anything to add to MAVEN_OPTS in ~/.mavenrc
#    maven_path_additions => "",      # anything to add to the PATH in ~/.mavenrc
#} 
#->
# # Create a settings.xml with the repo credentials
#maven::settings { 'maven-user-settings' :
#  mirrors => [$central], # mirrors entry in settings.xml, uses id, url, mirrorof from the hash passed
#  servers => [$central], # servers entry in settings.xml, uses id, username, password from the hash passed
#  proxies => [$proxy], # proxies entry in settings.xml, active, protocol, host, username, password, nonProxyHosts
#  user    => 'maven',
#}
# # defaults for all maven{} declarations
#Maven {
#  user  => "maven", # you can make puppet run Maven as a specific user instead of root, useful to share Maven settings and local repository
#  group => "maven", # you can make puppet run Maven as a specific group
#  repos => "http://repo.maven.apache.org/maven2"
#}
##

##
## Env
##

file { "/etc/profile.d/maven.sh":
	content => "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
							export MAVEN_HOME=/usr/share/maven
							export M2=\$MAVEN_HOME/bin
							export PATH=\$PATH:\$JAVA_HOME:\$M2
							export MAVEN_OPTS=\"-Xmx1024m -Xms512m\""
}

##
## ODL source
##

#vcsrepo {'/home/vagrant/odl_dev_ws':
#    ensure   => present,
#    provider => git,
#    user     => 'vagrant',
#    source   => 'https://git.opendaylight.org/gerrit/p/controller.git',
#    # source   => 'https://github.com/flavio-fernandes/devstack.git',
#    # revision => 'odlDevel',
##before   => File['/home/vagrant/devstack/local.conf'],
#}
#
#vcsrepo {'/home/vagrant/odl_dev_ws':
#    ensure   => present,
#    provider => git,
#    user     => 'vagrant',
#    source   => 'https://git.opendaylight.org/gerrit/p/ovsdb.git',
#    # source   => 'https://github.com/flavio-fernandes/devstack.git',
#    # revision => 'odlDevel',
##before   => File['/home/vagrant/devstack/local.conf'],
#}
