module LogConsumer
  module Kafka
    class Consumer
      def initialize(kafka_connection)
        @connection = kafka_connection
      end

      def self.with_seed_brokers(seed_brokers)
        new(::Kafka.new(seed_brokers: seed_brokers))
      end

      def consume(group_id:, topic_id:, &block)
        consumer = connection.consumer(group_id: group_id)
        consumer.subscribe(topic_id)

        consumer.each_message do |message|
          block.call(message)
        end
      end

      private

      attr_reader :connection
    end
  end
end
