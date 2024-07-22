<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

/**
 * List all the parameters required by the task
 */
function list_args()
{
  
}

$device_id_long = substr($context['device_id'], 3);

_configuration_variable_create ($device_id_long, "AUTH_HEADER", "Authorization: Bearer");
_configuration_variable_create ($device_id_long, "PROTOCOL", "http");
_configuration_variable_create ($device_id_long, "AUTH_MODE", "token");
_configuration_variable_create ($device_id_long, "SIGNIN_REQ_PATH", "/ubi-api-rest/auth/token ");
// uncomment to set the management port to 443 
//_configuration_variable_create ($device_id_long, "MANAGEMENT_PORT", "443");
//
task_success('Task OK');
?>