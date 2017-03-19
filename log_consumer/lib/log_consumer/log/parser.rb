module LogConsumer
  module Log
    class Parser
      attr_reader :matchers, :indexes

      def initialize
        @matchers = load_matchers
        @indexes  = load_indexes
      end

      def parse(host:, path:, message:)
        entries = {}

        matchers.each do |source, configs|
          if source == :all || host == source || (source.is_a?(Regexp) && host.match(source))
            configs.each do |config|
              if config[:path].nil? || config[:path] == path || (config[:path].is_a?(Regexp) && path.match(config[:path]))
                if config[:match].nil? || config[:match] == message || (config[:match].is_a?(Regexp) && message.match(config[:match]))
                  body = { "message" => message }
                  config[:split].each do |k, regex|
                    if thing_to_split = body[k.to_s]
                      match = thing_to_split.match(regex)
                      body.merge!(Hash[ match.names.zip( match.captures ) ])
                    end
                  end

                  entries[config[:index]] ||= []
                  entries[config[:index]] << body
                end
              end
            end
          end
        end

        entries
      end

      private

      def load_matchers
        { all: [{ match: /api\//,
                  index: "logstash-central-logging",
                  split: {
                             message: /(?<ip_address>(\d{1,3}\.){3}\d{1,3}).*\[(?<timestamp>.*)\].*(?<request_method>(GET|POST|PUT|DELETE))\s*(?<request_path>[^.]*)\.(?<request_format>\w+).*(?<response_code>\d{3}).*(?<response_time_ms>\d+)\s*"(?<referrer>[^"]*)"\s"(?<requesting_client>[^"]*)"/,
                             request_path: /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>\d+)\/advertiser_campaigns\/(?<advertiser_campaign_id>\d+)/
                         }
                }]
        }
      end

      def load_indexes
        { "logstash-central-logging" => { api_version: { type: "keyword" },
                                          timestamp:   { type: "date" } }
        }
      end
    end
  end
end
