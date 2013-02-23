#!/usr/bin/env ruby

require "rubygems"
require "aws-sdk"

msg = ARGV[0]
msg ||= STDIN.read

AWS.config(:sns_endpoint => "sns.ap-northeast-1.amazonaws.com")
sns = AWS::SNS.new
topics = sns.topics
topic = topics.create("cpustat")
topic.publish(msg)

