# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'prometheus_exporter/middleware'

if ENV['START_PROMETHEUS'] == 'true'
  # Start a local Prometheus Exporter server
  server = PrometheusExporter::Server::WebServer.new(
    bind: ENV['MONITORING_HOST'] || 'localhost',
    port: ENV['MONITORING_PORT'] || 9090
  )
  server.start

  # Use a local client to send metrics directly to the in-process collector
  PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)

  SQS_MESSAGE_PROCESS_COUNTER = PrometheusExporter::Metric::Counter.new(
    'sqs_messages_processed',
    'Counts the number of messages successfully processed from the SQS queue'
  )
  server.collector.register_metric(SQS_MESSAGE_PROCESS_COUNTER)
end
