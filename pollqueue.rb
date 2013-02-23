#!/usr/bin/env ruby

require "rubygems"
require "aws-sdk"
require "json"

trap(:INT){ exit }

AWS.config(:sqs_endpoint => "sqs.ap-northeast-1.amazonaws.com")
sqs = AWS::SQS.new
queues = sqs.queues
queue = queues.create("cpustat_queue")
queue.poll do |json|
	msg = JSON.load(json.body)
	puts msg["Message"]
end
