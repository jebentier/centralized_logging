require 'thor'
require 'terminal-table'
require 'kafka'
require 'elasticsearch'
require 'json'

module LogConsumer
  class CLI < Thor
    default_task :show

    desc 'show', 'Parses the DSL and outputs the matcher information'
    def show
      render([["method coming soon"]])
    end

    desc 'start', 'Starts the consumer'
    def start
      sleep 60

      consumer   = Kafka::Consumer.with_seed_brokers(['kafka:9092'])
      log_parser = Log::Parser.new
      esclient   = ::Elasticsearch::Client.new(hosts: [{ host: 'elasticsearch', port: '9200', scheme: 'http' }],
                                               log:   true)

      # Create indexes in case they doesn't exist yet
      log_parser.indexes.each do |index, properties|
        esclient.indices.create(index: index, body: { settings: { number_of_shards: 1 },
                                                      mappings: { type1: { properties: properties } } }) rescue nil
      end

      consumer.consume(group_id: 'centralized_log_consumer', topic_id: 'centralized_logs') do |message|
        log = JSON.parse(message.value)
        log_parser.parse(host: log["host"], path: log["path"], message: log["message"]).each do |index, bodies|
          bodies.each do |body|
            esclient.create(index: index, type: "type1", id: message.offset, body: body)
          end
        end
      end
    end

    private

    def render(matchers)
      puts ::Terminal::Table.new(headings: ["INDEX", "MATCH", "SPLIT"], rows: matchers).to_s
    end
  end
end
