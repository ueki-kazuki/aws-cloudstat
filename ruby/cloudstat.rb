#!/usr/bin/env ruby

require "rubygems"
require "aws-sdk"
require "json"
require "open-uri"
require "pp"

instance_id = URI.parse("http://169.254.169.254/latest/meta-data/instance-id").read

AWS.config(
	:cloud_watch_endpoint => "monitoring.ap-northeast-1.amazonaws.com"
)

cw = AWS::CloudWatch.new
metric = AWS::CloudWatch::Metric.new('AWS/EC2', 'CPUUtilization', 
	{:dimensions => [
		{:name => "InstanceId", :value => instance_id}
	]})
stats = metric.statistics(
	:start_time => Time.now - 600,
	:end_time => Time.now,
	:statistics => ['Average'])
latest = stats.first
puts "#{stats.metric.name}: #{latest[:average]} #{latest[:unit]}"
