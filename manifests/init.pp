# @summary Configures Lmod for use on an NCSA cluster.
#
# This profile installs and configures Lmod for use on an NCSA cluster.
#
# @example
#   include profile_lmod
#
# @param directories
#   Hash of directory data to ensure (as paths to managed modules).
#
# @param modules
#   Hash of modules that should be managed. Data takes the form:
#     "/path/to/modulefile":
#       data: {hash of data to pass to 'file' resource'
#       manage: Boolean
#   A few modules are managed/ensured by default, with provided
#   content. These can be NOT managed by specifying 'manage: false'.
#   Or customized by overriding their 'data'.
#   A SitePackage.lua file is also managed by default, to implement
#   basic module usage logging to syslog.
#
class profile_lmod (
  Hash $directories,
  Hash $modules,
) {

  $directory_defaults = {
    ensure => directory,
    group  => root,
    mode   => '0755',
    owner  => root,
  }

  ensure_resources( 'file', $directories, $directory_defaults )

  $file_defaults = {
    ensure => file,
    group  => root,
    mode   => '0644',
    owner  => root,
  }

  $modules.each | String $modulename, Hash $moduleparams | {
    if $moduleparams['manage'] {
      $moduledata = $moduleparams['data']
      ensure_resources( 'file', { $modulename => $moduledata }, $file_defaults )
    }
  }

  include ::lmod

}
