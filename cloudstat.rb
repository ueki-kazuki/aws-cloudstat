#!/usr/bin/env ruby

require "rubygems"
require "aws-sdk"
require "json"
require "open-uri"
require "pp"

instance_id = URI.parse("http://169.254.169.254/latest/meta-data/instance-id").read
json = URI.parse("http://169.254.169.254/latest/meta-data/iam/security-credentials/EC2-PowerRole").read
credential = JSON.load(json)

#puts instance_id
#pp credential

AWS.config(
	:access_key_id => credential["AccessKeyId"],
	:secret_access_key => credential["SecretAccessKey"],
	:session_token => credential["Token"],
	:cloud_watch_endpoint => "monitoring.ap-northeast-1.amazonaws.com"
)
cw = AWS::CloudWatch.new

#cw.metrics.with_namespace("AWS/EC2").with_metric_name("CPUUtilization").each do |metric|
#	puts "namespace = #{metric.namespace} metric = #{metric.name}"
#	metric.dimensions.each do |dimension|
#		puts "name = #{dimension[:name]}, value = #{dimension[:value]}"
#	end
#end

metric = AWS::CloudWatch::Metric.new('AWS/EC2', 'CPUUtilization', 
	{:dimensions => [
		{:name => "InstanceId", :value => instance_id}
	]})
stats = metric.statistics(
	:start_time => Time.now - 600,
	:end_time => Time.now,
	:statistics => ['Average'])
#stats.each do |datapoint|
#	pp datapoint
#end
latest = stats.first
puts "#{stats.metric.name}: #{latest[:average]} #{latest[:unit]}"
