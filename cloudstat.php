<?php
date_default_timezone_set('Asia/Tokyo');

require 'AWSSDKforPHP/aws.phar';

use Aws\CloudWatch\CloudWatchClient;
use Aws\Common\Enum\Region;
use Aws\Common\Credentials\RefreshableInstanceProfileCredentials;

#$credentials = new RefreshableInstanceProfileCredentials(Credentials::factory());
$client = CloudWatchClient::factory(array(
  #'credentials' => $credentials,
  'region' => Region::TOKYO,
));

try {
  $metrics = $client->listMetrics(array('Namespace'  => 'AWS/EC2'));
  foreach($metrics['Metrics'] as $metric) {
	  foreach($metric['Dimensions'] as $dimension) {
			printf("%s %s %s=%s\n",
							$metric['Namespace'], $metric['MetricName'],
							$dimension['Name'],   $dimension['Value']);
		}
  }
} catch(Aws\CloudWatch\Exception\CloudWatchException $e) {
  die($e->getMessage());
}
?>
