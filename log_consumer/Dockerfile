FROM ruby:2.4


RUN ln -sf /proc/1/fd/1 /var/log/log_consumer.log
RUN mkdir /src

WORKDIR /src

COPY ./ /src
RUN chmod +x -R /src

RUN bundle install

CMD ["bin/log-consumer", "start"]
