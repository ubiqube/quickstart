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


if ($context['var_name2'] % 2 === 0) {
	$ret = prepare_json_response(FAILED, 'Task Failed', $context, true);
	echo "$ret\n";
	exit;
}

/**
 * End of the task do not modify after this point
 */
task_exit(ENDED, "Task OK");

?>