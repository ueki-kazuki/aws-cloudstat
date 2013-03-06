#!/usr/bin/env ruby

require "rubygems"
require "aws-sdk"

message = ARGV.shift
message ||= STDIN.read.chomp

AWS.config(:sns_endpoint => "sns.ap-northeast-1.amazonaws.com")
sns = AWS::SNS.new
topic = sns.topics.create("cpustat")
topic.publish(message)
puts "send to topics [#{message}]"

