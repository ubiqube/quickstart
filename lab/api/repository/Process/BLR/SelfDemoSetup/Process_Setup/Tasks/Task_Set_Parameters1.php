<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

/**
 * List all the parameters required by the task
 */
function list_args() {
	create_var_def('customer_id', 'Integer');
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
	$context['password_admin'] = "";
}
if (!isset($context['device_ip_address'])) {
	$context['device_ip_address'] = "172.20.0.101";
}
if (!isset($context['device_external_reference'])) {
	$context['device_external_reference'] = "";
}
if (!isset($context['managementInterface'])) {
	$context['managementInterface'] = "eth0";
}  
if (!isset($context['snmpCommunity'])) {
	$context['snmpCommunity'] = "public";
}

/**
 * End of the task do not modify after this point
 */
task_exit(ENDED, "Task OK");

?>
