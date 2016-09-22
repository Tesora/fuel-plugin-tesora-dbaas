notice('MODULAR: trove/rabbitmq.pp')

$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$workers_max = hiera('workers_max', 50)

$queue_provider = hiera('queue_provider', 'rabbitmq')

if $queue_provider == 'rabbitmq' {
  $trove_hash      = hiera_hash('fuel-plugin-tesora-dbaas', {})
  $erlang_cookie   = hiera('erlang_cookie', 'EOKOWXQREETZSHFNTPEYT')
  $version         = hiera('rabbit_version', '3.3.5')
  $debug           = hiera('debug', false)
  $deployment_mode = hiera('deployment_mode', 'ha_compact')
  $amqp_port       = pick($trove_hash['rabbit_port'], '55671')
  $rabbit_hash     = hiera_hash('rabbit_hash', {})
  $enabled         = pick($rabbit_hash['enabled'], true)
  $use_pacemaker   = pick($rabbit_hash['pacemaker'], true)

  case $::osfamily {
    'RedHat': {
      $command_timeout  = '-s KILL'
      $package_provider = 'yum'
    }
    'Debian': {
      $command_timeout  = '--signal=KILL'
      $package_provider = 'apt'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem},\
  module ${module_name} only support osfamily RedHat and Debian")
    }
  }

  if ($debug) {
    # FIXME(aschultz): debug wasn't introduced until v3.5.0, when we upgrade
    # we should change info to debug. Also don't forget to fix tests!
    $rabbit_levels = '[{connection,info}]'
  } else {
    $rabbit_levels = '[{connection,info}]'
  }

  $cluster_partition_handling   = hiera('rabbit_cluster_partition_handling', 'autoheal')
  $mnesia_table_loading_timeout = hiera('mnesia_table_loading_timeout', '10000')
  $rabbitmq_bind_ip_address     = pick(get_network_role_property('trove/api', 'ipaddr'), 'UNSET')
  $management_bind_ip_address   = hiera('management_bind_ip_address', '127.0.0.1')
  $management_port              = hiera('rabbit_management_port', '15672')

  $configuration = hiera_hash('configuration', {})
  $config_vars = pick($configuration['rabbitmq'], {})

  $config_kernel_variables = pick(
    $config_vars['kernel'],
    hiera_hash('rabbit_config_kernel_variables', {})
  )
  $config_kernel_variables_default =       {
      'inet_dist_listen_min'         => '41055',
      'inet_dist_listen_max'         => '41055',
      'inet_default_connect_options' => '[{nodelay,true}]',
      'net_ticktime'                 => '10',
  }
  $config_kernel_variables_merged = merge ($config_kernel_variables_default, $config_kernel_variables)

  $config_variables_default = {
    'log_levels'                   => $rabbit_levels,
    'default_vhost'                => "<<\"/\">>",
    'default_permissions'          => '[<<".*">>, <<".*">>, <<".*">>]',
    'cluster_partition_handling'   => $cluster_partition_handling,
    'mnesia_table_loading_timeout' => $mnesia_table_loading_timeout,
    'disk_free_limit'              => '5000000', # Corosync checks for disk space, reduce rabbitmq check to 5M see LP#1493520 comment #15
  }

  $config_variables = pick($config_vars['application'], hiera_hash('rabbit_config_variables', {}))
  $config_variables_merged = merge($config_variables_default, $config_variables)

  $config_management_variables = pick($config_vars['management'], hiera_hash('rabbit_config_management_variables', {}))

  $config_management_variables_default ={
      'rates_mode' => 'none',
      'listener'   => "[{port, ${management_port}}, {ip,\"${management_bind_ip_address}\"}]",
    }

  $config_management_variables_merged = merge($config_management_variables_default, $config_management_variables)
  # NOTE(bogdando) to get the limit for threads, the max amount of worker processess will be doubled
  $thread_pool_calc = min($workers_max*2,max(12*$physicalprocessorcount,30))

  if $deployment_mode == 'ha_compact' {
    $rabbit_pid_file                   = '/var/run/rabbitmq/p_pid'
    } else {
    $rabbit_pid_file                   = '/var/run/rabbitmq/pid'
  }

  $environment_variables_init = hiera('rabbit_environment_variables',
    {
      'SERVER_ERL_ARGS'     => "\"+K true +A${thread_pool_calc} +P 1048576\"",
      'PID_FILE'            => $rabbit_pid_file,
    }
  )
  $environment_variables = merge($environment_variables_init,{'NODENAME' => "rabbit@${hostname}"})

  if ($enabled) {
    class { '::rabbitmq':
      admin_enable                => true,
      management_port             => $management_port,
      repos_ensure                => false,
      package_provider            => $package_provider,
      package_source              => undef,
      service_ensure              => 'running',
      service_manage              => true,
      port                        => $amqp_port,
      delete_guest_user           => true,
      default_user                => 'trove',
      default_pass                => $trove_hash['rabbit_password'],
      # NOTE(bogdando) set to true and uncomment the lines below, if puppet should create a cluster
      # We don't want it as far as OCF script creates the cluster
      config_cluster              => false,
      #erlang_cookie              => $erlang_cookie,
      #wipe_db_on_cookie_change   => true,
      #cluster_nodes              => $rabbitmq_cluster_nodes,
      #cluster_node_type          => 'disc',
      #cluster_partition_handling => $cluster_partition_handling,
      version                     => $version,
      node_ip_address             => $rabbitmq_bind_ip_address,
      config_kernel_variables     => $config_kernel_variables_merged,
      config_management_variables => $config_management_variables_merged,
      config_variables            => $config_variables_merged,
      environment_variables       => $environment_variables,
      tcp_keepalive               => true,
    }

    # Start epmd as rabbitmq so it doesn't run as root when installing plugins
    exec { 'epmd_daemon':
      command => 'epmd -daemon',
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      user    => 'rabbitmq',
      group   => 'rabbitmq',
      unless  => 'pgrep epmd',
    }
    # Make sure the various providers have their requirements in place.
    Class['::rabbitmq::install'] -> File['/etc/rabbitmq'] -> Exec['epmd_daemon']
      -> Rabbitmq_plugin<| |> -> Rabbitmq_exchange<| |>

    if ($use_pacemaker) {
      # Install rabbit-fence daemon
      class { 'cluster::rabbitmq_fence':
        enabled => $enabled,
        require => Class['::rabbitmq']
      }
    }

    class { 'tesora_dbaas::rabbitmq':
      enabled  => $enabled,
      # Do not install rabbitmq from trove classes
      rabbitmq_class => false,
      userid   => pick($trove_hash['rabbit_user'], 'trove'),
      password => $trove_hash['rabbit_password'],
      require  => Class['::rabbitmq'],
    }

    if ($use_pacemaker) {
      class { 'cluster::rabbitmq_ocf':
        command_timeout         => $command_timeout,
        debug                   => $debug,
        erlang_cookie           => $erlang_cookie,
        admin_user              => 'trove',
        admin_pass              => $trove_hash['rabbit_password'],
        host_ip                 => $management_bind_ip_address,
        before                  => Class['tesora_dbaas::rabbitmq'],
        pid_file                => $rabbit_pid_file,
        require                 => Class['::rabbitmq::install'],
      }
    }

    include ::rabbitmq::params
    tweaks::ubuntu_service_override { 'rabbitmq-server':
      package_name => $rabbitmq::params::package_name,
      service_name => $rabbitmq::params::service_name,
    }
  }
}
