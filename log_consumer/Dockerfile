FROM ruby:2.4


RUN ln -sf /proc/1/fd/1 /var/log/log_consumer.log
RUN mkdir /src

WORKDIR /src

COPY ./Gemfile Gemfile
RUN bundle install

COPY ./ /src
RUN chmod +x -R /src

CMD "/src/consume_logs"
