<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

function list_args()
{
  
}

$device_id_long = substr($context['device_id'], 3);

$customer_id_long = substr($context['customer_id'], 4);

$response = _profile_configuration_create ($customer_id_long, "linux_ds", $reference = "", $comment = "", $manufacturer_id = "14020601", $model_id = "14020601");

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
echo $response;

// CommandDefinition/LINUX/SYSTEM/user.xml
$files = array( "0" => "CommandDefinition/LINUX/SYSTEM/user.xml");
debug_dump($files, "URIs");
$response = _profile_configuration_attach_files ($ds_id, $files, "AUTO");
if ($response['wo_status'] !== ENDED) {
	$response = json_encode($response);
	echo $response;
	exit;
}

$response = prepare_json_response(ENDED, 'Task OK: DS '.$context["ds_reference"].' associated to ME ' . $context['device_id'], $context, true);
echo $response;

?>