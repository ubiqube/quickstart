<?php

/**
 * This file is necessary to include to use all the in-built libraries of /opt/fmc_repository/Reference/Common
 */
require_once '/opt/fmc_repository/Process/Reference/Common/common.php';

/**
 * list all the parameters required by the task
 */
function list_args() {
//	create_var_def ( 'microservice', 'String' );
   	create_var_def ( 'top10.0.id', 'String' );
   	create_var_def ( 'top10.0.user', 'String' );
   	create_var_def ( 'top10.0.pr', 'String' );
   	create_var_def ( 'top10.0.ni', 'String' );
   	create_var_def ( 'top10.0.virt', 'String' );
   	create_var_def ( 'top10.0.res', 'String' );
   	create_var_def ( 'top10.0.shr', 'String' );
   	create_var_def ( 'top10.0.s', 'String' );
   	create_var_def ( 'top10.0.cpu', 'String' );
   	create_var_def ( 'top10.0.mem', 'String' );
   	create_var_def ( 'top10.0.time', 'String' );
   	create_var_def ( 'top10.0.command', 'String' );

   	create_var_def ( 'date', 'String' );
}

$context['date'] = date('D M j G:i:s T Y');
/**
 * iterate through the array of devices in order to apply the policy for each device
 */
foreach ( $context ['devices'] as $deviceidRow ) {
	/**
	 * extract the device database identifier from the device ID
	 */
	$devicelongid = substr ( $deviceidRow ['id'], 3 );
	logToFile ( "***************************" );
	logToFile ( "get TOP 10 processes on $devicelongid" );
	
	/**
	 * build the Microservice JSON params for the IMPORT operation of the microservice
	 */
	
	$microservice = "top";
	
	$micro_service_vars_array = array ();
	$micro_service_vars_array ['0'] = "";

	$microservice = array (
			$microservice => array (
				$micro_service_vars_array
			)
	);


	/**
	 * call the IMPORT for simple_firewall MS for each device
	 */
	$response = execute_command_and_verify_response ( $devicelongid, CMD_IMPORT, $microservice, "Import Microservice" );
	$response = json_decode ( $response, true );
	if ($response ['wo_status'] === ENDED) {
		
		$content = $response['wo_newparams']['top'];
		$i= 0;
		foreach ($content as $line) {
			$context['top10'][$i]['id'] = $line['object_id'];
                        $context['top10'][$i]['user'] = $line['user'];
                        $context['top10'][$i]['pr'] = $line['pr'];
                        $context['top10'][$i]['ni'] = $line['ni'];
                        $context['top10'][$i]['virt'] = $line['virt'];
                        $context['top10'][$i]['res'] = $line['res'];
                        $context['top10'][$i]['shr'] = $line['shr'];
                        $context['top10'][$i]['cpu'] = $line['cpu'];
                        $context['top10'][$i]['mem'] = $line['mem'];
                        $context['top10'][$i]['time'] = $line['time'];
                        $context['top10'][$i]['command'] = $line['command'];
			$i++;
		}
				
		$response = prepare_json_response ( $response ['wo_status'], $response ['wo_comment'], $context, true );
		echo $response;
	} else {
		task_exit ( FAILED, "Task FAILED" );
	}
}

/**
 * End of the task do not modify after this point
 */
task_exit ( ENDED, "Task OK" );

?>
