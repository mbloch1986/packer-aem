include ::config::base

include aem_curator::install_java

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_aem { 'Setup CloudWatch for AEM Publish':
    aem_id => 'publish',
  }
}

if $::config::base::install_collectd {
  collectd::plugin::java { 'Install collectd Java plugin':
    manage_package => true,
  } -> collectd::plugin::genericjmx { 'Install collectd JMX plugin':
    manage_package => true,
  }
}
