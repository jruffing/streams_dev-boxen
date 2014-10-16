require boxen::environment
require homebrew
require gcc


Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  #include dnsmasq
  include git
  include hub
  #include nginx
  
  # Use my own gitconfig
  include alfred
  include brewcask
  include caffeine
  include chrome
  include evernote
  include firefox
  include github_for_mac
  include intellij
  include iterm2::stable
  include mou
  include onepassword
  include osx
  include pycharm
  include python
  include skype
  include sublime_text_3
  include tunnelblick
  include unarchiver
  include vagrant
  include vagrant_manager
  include virtualbox


  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.10': }
  nodejs::version { 'v0.8': }
  class { 'nodejs::global': version => 'v0.10' }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.1.2': }

  # python versions
  python::version { '2.7.8': }
  python::version { '3.4.1': }
  python::version { 'pypy-2.3.1': }
  include python::global

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }


  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
