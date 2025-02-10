# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'prometheus_exporter/middleware'

if ENV['START_PROMETHEUS'] == 'true'
  # Start a local Prometheus Exporter server
  server = PrometheusExporter::Server::WebServer.new(bind: ENV['MONITORING_HOST'] || 'localhost',
                                                     port: ENV['MONITORING_PORT'] || 9090)
  server.start

  # Use a local client to send metrics directly to the in-process collector
  PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)

  SMS_PROVIDER_REQ_COUNTER = PrometheusExporter::Metric::Counter.new(
    'sqs_requestes',
    'Counts SMS provider API requests by provider and HTTP status code'
  )
  server.collector.register_metric(SMS_PROVIDER_REQ_COUNTER)
end
