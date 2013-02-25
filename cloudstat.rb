#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'pp'
require 'open-uri'
require 'json'

role = "EC2-PowerRole"
endpoint = "monitoring.ap-northeast-1.amazonaws.com"

instanceid = URI.parse("http://169.254.169.254/latest/meta-data/instance-id").read

js = ""
open("http://169.254.169.254/latest/meta-data/iam/security-credentials/#{role}") { |resp|
	resp.each_line { |line|
		js += line
  }
}
credential = JSON.load(js)

#instanceid = "i-2f46772c"
AWS.config(
  :cloud_watch_endpoint => endpoint,
  :access_key_id => credential["AccessKeyId"],
  :secret_access_key => credential["SecretAccessKey"],
  :session_token => credential["Token"]
)
#AWS.config(
#  :cloud_watch_endpoint => "monitoring.ap-northeast-1.amazonaws.com",
#  :access_key_id => 'ASIAIQMRX25QCTYKKSJA',
#  :secret_access_key => 'zzRAPiF6cH19bTW5LZE84F7th7J9silSmKa5QnfD',
#  :session_token => 'AQoDYXdzEHQaoAKIGBTvD4MeKc/WOIW61+fIALrEazekAVgt5F/OH38Y1IJikkm6bgrer2jii3a6O2ONIxiqDTmAptsZFWbQfIiNMW/mMas7egbL+nCHGkM/7MsLcBvG0wZMRoTOwH25PkI3njvZ5+kK1FCzeTqY1Lr6V5+B8QO2QxbKtkYsVlsoDRKtWRyZHCpcIQEeHcZ4IAlyF3fo7lWWTTo5PhO7E/0sfMmvRADF/qQOwsP1XMcf0MNt61bcXe3rXJN88wGunmnzJuZGyb7eHh7HY5o6FM8oCG/c5/zb1wvlmEKC267t4uyb1zQOVhmJfNRr0/y6w3s+hD5uks5G9uhUtWPSsYeBypdGuLOg/L7MnSybOs/RlNVvNICbh8wRdrkrl4XzThkgg9KSiQU=')
#instanceid = "i-2f46772c"

cw = AWS::CloudWatch.new

#metrics = cw.metrics
#metrics.each do |metric|
#	puts "metric: #{metric.name}"
#end

#resp = cw.client.list_metrics(
#  :namespace => 'AWS/EC2',
#  :dimensions => [:name => 'InstanceId', :value => instanceid],
#  :metric_name => "CPUUtilization"
#)
#resp[:metrics].each do |metric|
#	metric[:dimensions].each do |dimension|
#		puts "#{metric[:namespace]} #{metric[:metric_name]} #{dimension[:name]}"
#	end
#end


#resp = cw.client.get_metric_statistics[
#	:metric_name => "CPUUtilization"
#	:]


#metric = AWS::CloudWatch::Metric.new('my/namespace', 'CPUUtilization')
#stats = metric.statistics(
#	:start_time => Time.now - 60,
#	:end_time   => Time.now,
#	:statistics => ['Average'])
#stats.label
#stats.each do |datapoint|
#	puts datapoint
#end


stats = cw.client.get_metric_statistics(
	:namespace => 'AWS/EC2', 
	:metric_name => "CPUUtilization",
	:dimensions => [:name => 'InstanceId', :value => instanceid],
	:start_time => (Time.now - 600).iso8601,
	:end_time => Time.now.iso8601,
	:period => 60,
	:statistics => [ 'Average' ]
	)
point = stats[:datapoints].shift
puts point[:average]
