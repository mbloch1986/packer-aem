define config::kinesis_agent (
  $kinesis_agent_user_name  = 'aws-kinesis-agent-user',
  $kinesis_agent_user_group = undef,
){
  $aws_kinesis_agent_package_dependencies = [
                                              'geronimo-jms',
                                              'javamail',
                                              'log4j',
                                            ]

  $aws_kinesis_agent_package_dependencies.each | $aws_kinesis_agent_package_dependency| {
    package { $aws_kinesis_agent_package_dependency:
      ensure   => present,
      provider => 'yum',
      before   => Package['aws-kinesis-agent'],
    }
  }

  $aws_kinesis_agent_source = 'https://s3.amazonaws.com/streaming-data-agent/aws-kinesis-agent-latest.amzn1.noarch.rpm'

  package { 'aws-kinesis-agent':
    ensure   => present,
    provider => rpm,
    source   => $aws_kinesis_agent_source,
    }

  if $kinesis_agent_user_group {
    user { $kinesis_agent_user_name:
      groups  => $kinesis_agent_user_group,
      require => Package['aws-kinesis-agent'],
    }
  }
}
