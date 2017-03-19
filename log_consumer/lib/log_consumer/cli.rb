require 'thor'
require 'terminal-table'
require 'kafka'
require 'elasticsearch'

module LogConsumer
  class CLI < Thor
    default_task :show

    desc 'show', 'Parses the DSL and outputs the matcher information'
    def show
      render([["method coming soon"]])
    end

    desc 'start', 'Starts the consumer'
    def start
      consumer   = Kafka::Consumer.with_seed_brokers(['kafka:9092'])
      log_parser = Log::Parser.new
      esclient   = ::Elasticsearch::Client.new(hosts: [{ host: 'elasticsearch', port: '9200', scheme: 'http' }],
                                               log:   true)

      # Create the index in case it doesn't exist yet
      esclient.indices.create(index: 'logstash-central_logging',
                              body:  { settings: { number_of_shards: 1 },
                                       mappings: { type1: { properties: { api_version: { type: "keyword" },
                                                                          timestamp:   { type: "date" } } } } }) rescue nil

      consumer.consume(group_id: 'centralized_log_consumer', topic_id: 'centralized_logs') do |message|
        log_parser.parse(message.value).each do |index, bodies|
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
