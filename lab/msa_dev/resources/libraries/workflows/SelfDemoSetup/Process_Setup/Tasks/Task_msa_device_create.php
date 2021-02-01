<?php

require_once '/opt/fmc_repository/Process/Reference/Common/common.php';
//require_once '/opt/fmc_repository/Process/BLR/SelfDemoSetup/Process_Setup/Tasks/device_rest.php';

function list_args() {
	create_var_def('managed_device_name', 'String');
	create_var_def('device_external_reference', 'String');
	create_var_def('manufacturer_id', 'Integer');
	create_var_def('model_id', 'Integer');
	create_var_def('device_ip_address', 'IP Address');
	create_var_def('login', 'String');
	create_var_def('password', 'Password');
	create_var_def('password_admin', 'Password');
    create_var_def('managementInterface', 'String');
    create_var_def('snmpCommunity', 'String');
    create_var_def('hostname', 'String');
	create_var_def('management_port', 'Integer');
}

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
$log_more_enabled = "false";
$mail_alerting = "false";
$reporting = "false";
$snmp_community = $context['snmpCommunity'];
$managementInterface = $context['managementInterface'];
$hostname = $context['hostname'];
$management_port = $context['management_port'];

$response = _device_create($customer_db_id, $device_name, $manufacturer_id,
							$model_id, $login, $password, $password_admin, 
							$management_address, $device_external_reference, 
							$log_enabled = "true", $log_more_enabled = "false",
							$mail_alerting = "false", $reporting = "false", $snmp_community, 
							$managementInterface, $hostname, $management_port);

$response = json_decode($response, true);
if ($response['wo_status'] !== ENDED) {
	$response = json_encode($response);
	echo $response;
	exit;
}
$device_id = $response['wo_newparams']['entity']['externalReference'];
$context['device_id'] = $device_id;
$device_id_long = substr($device_id, 3);

_device_set_nature_by_id($device_id_long, "VPRV");

$wo_comment = "ID  : $device_id";
$response = prepare_json_response(ENDED, "Managed entity created successfully.\n$wo_comment", $context, true);
echo $response;

?>
