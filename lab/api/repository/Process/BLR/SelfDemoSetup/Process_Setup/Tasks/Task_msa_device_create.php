<?php

require_once '/opt/fmc_repository/Process/Reference/Common/common.php';
//require_once '/opt/fmc_repository/Process/BLR/SelfDemoSetup/Process_Setup/Tasks/device_rest.php';

function list_args() {
	create_var_def('customer_id', 'Integer');
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
}

check_mandatory_param('customer_id');
check_mandatory_param('managed_device_name');
check_mandatory_param('manufacturer_id');
check_mandatory_param('model_id');
check_mandatory_param('login');
check_mandatory_param('password');

// MSA device creation parameters
$customer_id = $context['customer_id'];
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


if (array_key_exists('device_external_reference', $context)) {
	$device_external_reference = $context['device_external_reference'];
}

//$response = _device_create($customer_id, $managed_device_name, $manufacturer_id,
//							$model_id, $login, $password, $password_admin, 
// $device_ip_address, $device_external_reference);


$array = array('name' => $device_name,
			'manufacturerId' => $manufacturer_id,
			'modelId' => $model_id,
			'login' => $login,
			'password' => $password,
			'passwordAdmin' => $password_admin,
			'logEnabled' => $log_enabled,
			'logMoreEnabled' => $log_more_enabled,
			'mailAlerting' => $mail_alerting,
			'reporting' => $reporting,
			'managementAddress' => $management_address,
			'externalReference' => $device_external_reference,
			'snmpCommunity' => $snmp_community,
			'managementInterface' => $managementInterface,
	);
	$json = json_encode($array);
	$msa_rest_api = "device/{$customer_id}";
	$curl_cmd = create_msa_operation_request(OP_PUT, $msa_rest_api, $json);
	$response = perform_curl_operation($curl_cmd, "CREATE MANAGED ENTITY");
	$response = json_decode($response, true);
	if ($response['wo_status'] !== ENDED) {
		$response = json_encode($response);
		return $response;
	}
	$response = prepare_json_response(ENDED, ENDED_SUCCESSFULLY, $response['wo_newparams']['response_body']);


$response = json_decode($response, true);
if ($response['wo_status'] !== ENDED) {
	$response = json_encode($response);
	echo $response;
	exit;
}
$device_id = $response['wo_newparams']['entity']['externalReference'];
$wo_comment = "Managed Entity External Reference : $device_id";
logToFile($wo_comment);
	
$context['device_id'] = $device_id;
$response = prepare_json_response(ENDED, "Managed entity created successfully.\n$wo_comment", $context, true);
echo $response;

?>
