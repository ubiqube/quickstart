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
_device_delete($device_id_long);

if (isset($context["ds_id"])) {
 $ds_id = $context["ds_id"];
 $customer_id_long = substr($context['customer_id'], 4);
 _profile_configuration_delete_by_id($customer_id_long, $ds_id);
 task_success("ME ".$context['device_id']." , DS ".$context["ds_reference"]." deleted" );

} else {
  task_success("ME ".$context['device_id']." deleted" );
}     
?>