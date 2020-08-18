<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

/**
 * List all the parameters required by the task
 */
function list_args() {
	create_var_def('managed_device_name', 'String');
	create_var_def('device_external_reference', 'String');
	create_var_def('manufacturer_id', 'Integer');
	create_var_def('model_id', 'Integer');
	create_var_def('device_ip_address', 'IpAddress');
	create_var_def('login', 'String');
	create_var_def('password', 'Password');
	create_var_def('password_admin', 'Password');
	create_var_def('managementInterface', 'String');
	create_var_def('snmpCommunity', 'String');
}

$PROCESSINSTANCEID = $context['PROCESSINSTANCEID'];
$EXECNUMBER = $context['EXECNUMBER'];
$TASKID = $context['TASKID'];
$process_params = array('PROCESSINSTANCEID' => $PROCESSINSTANCEID,
						'EXECNUMBER' => $EXECNUMBER,
						'TASKID' => $TASKID);

$context['customer_id'] = $context['UBIQUBEID'];



// MSA device creation parameters
if (!isset($context['managed_device_name'])) {
	$context['managed_device_name'] = "linux_me";
}
if (!isset($context['manufacturer_id'])) {
	$context['manufacturer_id'] = 14020601;
}
if (!isset($context['model_id'])) {
	$context['model_id'] = 14020601;
}
if (!isset($context['login'])) {
	$context['login'] = "msa";
}
if (!isset($context['password'])) {
	$context['password'] = "ubiqube";
}
if (!isset($context['password_admin'])) {
	$context['password_admin'] = "____";
}
if (!isset($context['device_ip_address'])) {
	$context['device_ip_address'] = "172.20.0.101";
}
if (!isset($context['device_external_reference'])) {
	$context['device_external_reference'] = "____";
}
if (!isset($context['managementInterface'])) {
	$context['managementInterface'] = "eth0";
}  
if (!isset($context['snmpCommunity'])) {
	$context['snmpCommunity'] = "public";
}

if (!isset($context['management_port'])) {
	$context['management_port'] = 22;
}



check_mandatory_param('customer_id');
check_mandatory_param('managed_device_name');
check_mandatory_param('manufacturer_id');
check_mandatory_param('model_id');
check_mandatory_param('login');
check_mandatory_param('password');


// MSA device creation parameters
$customer_id = $context['customer_id'];
$customer_db_id = substr($customer_id,4);
$device_name = $context['managed_device_name'];
$manufacturer_id = $context['manufacturer_id'];
$model_id = $context['model_id'];
$login = $context['login'];
$password = $context['password'];
$password_admin = $context['password_admin'];
$management_address = $context['device_ip_address'];
$device_external_reference = "";
$log_enabled = "true";
$log_more_enabled = "true";
$mail_alerting = "true";
$reporting = "false";
$snmp_community = $context['snmpCommunity'];
$managementInterface = $context['managementInterface'];
$management_port = $context['management_port'];

$response = _device_create($customer_db_id, $device_name, $manufacturer_id,
							$model_id, $login, $password, $password_admin, 
							$management_address, $device_external_reference, $log_enabled = "true", 
							$log_more_enabled = "true",$mail_alerting = "true", $reporting = "true", 
							$snmp_community, $hostname ="", $management_port);

$response = json_decode($response, true);
if ($response['wo_status'] !== ENDED) {
	$response = json_encode($response);
	echo $response;
	exit;
}
$device_id = $response['wo_newparams']['entity']['externalReference'];
$context['device_id'] = $device_id;
$device_id_long = substr($device_id, 3);

_device_do_initial_provisioning_by_id($device_id_long);

$wo_comment = "ID  : $device_id";
$response = prepare_json_response(ENDED, "Managed entity created successfully.\n$wo_comment", $context, true);
echo $response;

?>
