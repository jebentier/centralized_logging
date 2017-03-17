class KafkaConsumer
  def initialize(kafka_connection)
    @connection = kafka_connection
  end

  def self.with_seed_brokers(seed_brokers)
    new(Kafka.new(seed_brokers: seed_brokers))
  end

  def consume(group_id:, topic_id:)
    
  end

  private

  attr_reader :kafka_connection

end
