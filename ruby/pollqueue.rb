#!/usr/bin/env ruby

require "rubygems"
require "aws-sdk"
require "json"

queue_name = "cpustat_queue"

trap(:INT){ exit }

AWS.config(:sqs_endpoint => "sqs.ap-northeast-1.amazonaws.com")
sqs = AWS::SQS.new
queue = sqs.queues.create(queue_name)
queue.poll do |msg|
	json = JSON.load(msg.body)
	puts "Got messsage: #{json['Message']}"
end
