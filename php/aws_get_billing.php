<?php
date_default_timezone_set('Asia/Tokyo');

require 'AWSSDKforPHP/aws.phar'; 
use Aws\Ec2\Ec2Client; 
use Aws\CloudWatch\CloudWatchClient; 
use Aws\CloudWatch\Enum\Statistic; 
use Aws\Common\Enum\Region; 
use Aws\Common\Credentials\RefreshableInstanceProfileCredentials; 
 
$config = array('region' => Region::US_EAST_1); 
# CloudWatchを使って情報を収集する 
$cw = CloudWatchClient::factory($config); 

function listMetrics($dimensions) { 
  global $cw;
  try { 
    $metrics = $cw->listMetrics(array('Dimensions' => $dimensions)); 
    foreach($metrics['Metrics'] as $metric) { 
      foreach($metric['Dimensions'] as $dimension) { 
        printf("%10s %-30s %s=%s\n", 
                $metric['Namespace'], $metric['MetricName'], 
                $dimension['Name'],   $dimension['Value']); 
      } 
    } 
  } catch(Aws\CloudWatch\Exception\CloudWatchException $e) { 
    die($e->getMessage()); 
  } 
} 
 
 
# 異なるNamespaceを一度に取得することはできないようだ 
function listBillingMetrics() { 
  $dimensions = array(); 
  listMetrics($dimensions); 
} 
 
function listBillingStatistics() { 
  global $cw; 
 
  try { 
    $metrics = $cw->listMetrics(array(
      'Namespace'  => 'AWS/Billing', 
      'MetricName' => 'EstimatedCharges', 
		)); 
    foreach($metrics['Metrics'] as $metric) { 
			# Dimensions must be set (if not set statistics returns empty value)
			# StartTime must be set at least 4 hours by now.
			# Billing statistic is "MAXIMUM" only.
		  $stats = $cw->getMetricStatistics(array( 
		    'Namespace'  => $metric['Namespace'],
		    'MetricName' => $metric['MetricName'],
		    'Dimensions' => $metric['Dimensions'], 
			  'StartTime'  => strtotime('-4 hour'),
			  'EndTime'    => strtotime('now'),
		    'Period'     => 60, 
		    'Statistics' => array(Statistic::MAXIMUM), 
		  )); 
		  foreach($stats->get('Datapoints') as $dp) { 
				foreach($metric['Dimensions'] as $dimension) {
					if ($dimension['Value'] != 'USD') {
						printf("%s=%s (%s)\n", $dimension['Value'], $dp['Maximum'], $dp['Timestamp']); 
					}
				}
		  } 
    } 
	} catch(Aws\CloudWatch\Exception\CloudWatchException $e) {
	  die($e->getMessage());
  } catch(Exception $other) { 
    die($other->getMessage()); 
	}
}

listBillingMetrics();
listBillingStatistics();

?>
