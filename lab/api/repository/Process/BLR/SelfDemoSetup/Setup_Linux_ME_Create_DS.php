<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

function list_args()
{
  
}
$device_id = $context['device_id'];
$device_id_long = substr($device_id, 3);

$customer_id_long = substr($context['customer_id'], 4);
$ds_name = $context['managed_device_name']."_ds";

$response = _profile_configuration_create ($customer_id_long, $ds_name, $reference = "", $comment = "", $manufacturer_id = "14020601", $model_id = "14020601");

$response = json_decode($response, true);
if ($response['wo_status'] !== ENDED) {
	$response = json_encode($response);
	echo $response;
	exit;
}

$ds_id = $response['wo_newparams']['id'];
$ds_ref = $response['wo_newparams']['ubiId'];

$context["ds_id"] = $ds_id;
$context["ds_reference"] = $ds_ref;

$response = _profile_attach_to_device_by_reference ($context["ds_reference"], $context['device_id']);
$response = json_decode($response, true);

// CommandDefinition/LINUX/SYSTEM/user.xml

$files = array();
$files = json_decode('[{"uri" : "CommandDefinition/LINUX/SYSTEM/user.xml" }, {"uri" : "CommandDefinition/LINUX/Orchestration/simple_firewall.xml"}]', true);
debug_dump($files, "URIs");
_profile_configuration_attach_files ($ds_id, $files, "AUTO");

task_exit(ENDED, "DS $ds_ref associated to ME ".$device_id);

?>