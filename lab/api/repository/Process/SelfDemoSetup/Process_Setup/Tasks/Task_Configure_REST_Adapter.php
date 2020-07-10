<?php

require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

function list_args()
{
  
}

$device_id_long = substr($context['device_id'], 3);
$device_private_address = $context["device_private_address"];
_configuration_variable_create ($device_id_long, "AUTH_HEADER", "Authorization: Bearer");
_configuration_variable_create ($device_id_long, "AUTH_MODE", "token");
_configuration_variable_create ($device_id_long, "SIGNIN_REQ_PATH", "/ubi-api-rest/auth/token ");


task_success('Task OK');
?>