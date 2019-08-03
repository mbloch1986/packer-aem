define config::package_installation (
  $package_manager_packages = {},
) {

  $package_manager_packages.each | Integer $index, $package_details| {

    $package_name = $package_details['name']

    $package_version = pick(
      $package_details['version'],
      'latest'
    )

    $package_provider = pick(
      $package_details['provider'],
      false
    )

    if $package_provider {
      package { $package_name:
        ensure   => $package_version,
        provider => $package_provider,
      }
    } else {
      package { $package_name:
        ensure => $package_version,
      }
    }
  }
}
