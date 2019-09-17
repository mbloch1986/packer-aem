define config::kinesis_agent (
  $kinesis_agent_user_name  = 'aws-kinesis-agent-user',
  $kinesis_agent_user_group = undef,
  $kinesis_config           = {}
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

  if $kinesis_configuration {
    file { "/etc/aws-kinesis/agent.json":
      ensure  => present,
      mode    => '0640',
      owner   => 'root',
      group   => $kinesis_agent_user_group,
      content => epp(
        'aws/kinesis/aws-kinesis-agent.json.epp',
        {
          'aws_region' => $aws_region
        }
      ),
    }

    $kinesis_configuration.each | String $named_index, Tuple $flows_raw| {
      $flows = to_json_pretty($flows_raw)
      file { "/etc/aws-kinesis/agent.d/$index.json":
        ensure  => present,
        mode    => '0640',
        owner   => 'root',
        group   => $kinesis_agent_user_group,
        content => epp(
          'aws/kinesis/aws-kinesis-flows.json.epp',
          {
            'kinesis_flows' => $flows
          }
        ),
      }
    }
  }
}
