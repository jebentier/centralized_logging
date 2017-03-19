FROM ruby:2.4

RUN ln -sf /proc/1/fd/1 /var/log/log_consumer.log
RUN mkdir -p /src/lib/log_consumer

WORKDIR /src

COPY ./lib/log_consumer/version.rb lib/log_consumer/version.rb
COPY ./Gemfile Gemfile
COPY ./log_consumer.gemspec log_consumer.gemspec
RUN bundle install

COPY ./ /src
RUN chmod +x -R /src

CMD ["bin/log-consumer", "start"]
