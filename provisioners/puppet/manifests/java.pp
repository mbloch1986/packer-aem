include ::config::base

include ::config::certs

include aem_curator::install_java

if $::config::base::install_cloudwatchlogs {
  config::cloudwatchlogs_java { 'Setup CloudWatch for Java': }
}



if $::config::base::install_cloudwatch_metric_agent {
  config::cloudwatch_metric_agent { 'Setup Cloudwatch Metric Agent for Java':
    disk_path => [
      $::config::base::metric_root_disk_path
    ]
  }
}

include config::tomcat

if $::config::base::install_kinesis_agent {
  config::kinesis_agent { 'Setup AWS Kinesis agent':
    kinesis_agent_user_group => $::config::os_group
  }
}

