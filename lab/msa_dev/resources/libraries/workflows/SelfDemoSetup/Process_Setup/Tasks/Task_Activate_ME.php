<?php

require_once '/opt/fmc_repository/Process/Reference/Common/common.php';
//require_once '/opt/fmc_repository/Process/BLR/SelfDemoSetup/Process_Setup/Tasks/device_rest.php';

function list_args() {
}

$device_id = $context['device_id'];
$device_id_long = substr($device_id, 3);

_device_do_initial_provisioning_by_id($device_id_long);

$wo_comment = "ID  : $device_id";
$response = prepare_json_response(ENDED, "Managed entity activated successfully.\n$wo_comment", $context, true);
echo $response;

?>
