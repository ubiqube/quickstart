<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

/**
 * List all the parameters required by the task
 */
function list_args() {
	//create_var_def('customer_id', 'Integer');
	create_var_def('managed_device_name', 'String');
	create_var_def('device_external_reference', 'String');
	create_var_def('manufacturer_id', 'Integer');
	create_var_def('model_id', 'Integer');
	//create_var_def('device_ip_address', 'IpAddress');
	create_var_def('login', 'String');
	create_var_def('password', 'Password');
	//create_var_def('password_admin', 'Password');
	create_var_def('managementInterface', 'String');
	create_var_def('snmpCommunity', 'String');
    create_var_def('hostname', 'String');
	create_var_def('management_port', 'Integer');
}

// MSA device creation parameters
if (!isset($context['managed_device_name'])) {
  $context['managed_device_name'] = "msa_rest_api";
}
$context['manufacturer_id'] = 191119;
$context['model_id'] = 191119;
$context['login'] = "ncroot";
$context['password'] = "ubiqube";
$context['password_admin'] = "";
$context['device_external_reference'] = "";
$context['managementInterface'] = "eth0";
$context['snmpCommunity'] = "public";
$context['hostname'] = "rest-me";
// port set to 22 on purpose for troubleshooting hands-on
$context['management_port'] = 22;

$host= gethostname();
$ip = gethostbyname($host);
$context['device_ip_address'] = $ip;


$PROCESSINSTANCEID = $context['PROCESSINSTANCEID'];
$EXECNUMBER = $context['EXECNUMBER'];
$TASKID = $context['TASKID'];
$process_params = array('PROCESSINSTANCEID' => $PROCESSINSTANCEID,
						'EXECNUMBER' => $EXECNUMBER,
						'TASKID' => $TASKID);

$context['customer_id'] = $context['UBIQUBEID'];

/**
 * End of the task do not modify after this point
 */
task_exit(ENDED, "Task OK");

?>
