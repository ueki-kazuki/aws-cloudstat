<?php
date_default_timezone_set('Asia/Tokyo');

require 'AWSSDKforPHP/aws.phar';

use Aws\Ec2\Ec2Client;
use Aws\CloudWatch\CloudWatchClient;
use Aws\Common\Enum\Region;
use Aws\Common\Credentials\RefreshableInstanceProfileCredentials;

$config = array('region' => Region::TOKYO);

# instance metadata から instance-id を取得する
$fh = fopen('http://169.254.169.254/latest/meta-data/instance-id', 'r');
$instanceid = fgets($fh);
fclose($fh);

function listMetrics($dimensions) {
	global $config;
	# CloudWatchを使って情報を収集する
	$cw = CloudWatchClient::factory($config);
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
function listEc2Metrics() {
	global $instanceid;
	$dimensions = array();
	array_push($dimensions, array('Name' => 'InstanceId', 'Value' => $instanceid));
	listMetrics($dimensions);
}

# このEC2インスタンスに紐づいたEBSなどのリソース情報を取得する
function listEbsMetrics() {
	global $config, $instanceid;
	$dimensions = array();
	$ec2 = Ec2Client::factory($config);
	$instances = $ec2->describeInstances(array('InstanceIds' => array($instanceid)));
	foreach($instances['Reservations'] as $reservation) {
		foreach($reservation['Instances'] as $instance) {
			foreach($instance['BlockDeviceMappings'] as $device) {
				array_push($dimensions, array('Name' => 'VolumeId', 'Value' => $device['Ebs']['VolumeId']));
			}
		}
	}
	listMetrics($dimensions);
}

listEc2Metrics();
listEbsMetrics();

?>
