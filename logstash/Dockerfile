FROM docker.elastic.co/logstash/logstash:5.2.1

RUN logstash-plugin install logstash-output-kafka

USER root

RUN touch /var/log/test.log
RUN chmod 777 /var/log/test.log

COPY demo_logger.sh /demo_logger.sh
RUN chmod 777 /demo_logger.sh

USER logstash
