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
                  entries[config[:index]] ||= []
                  entries[config[:index]] << parse_message_for_config(message, config)
                end
              end
            end
          end
        end

        entries
      end

      private

      def parse_message_for_config(message, config)
        body = { "message" => message }

        config[:split].each do |k, regexes|
          regexes = regexes.is_a?(Array) ? regexes : [regexes]
          if thing_to_split = body[k.to_s]
            regex = regexes.find { |pattern| thing_to_split =~ pattern }
            match = split_message(thing_to_split, regex)
            body.merge!(match) if match
          end
        end

        body
      end

      def split_message(thing_to_split, regex)
        match = thing_to_split.match(regex)
        if match
          Hash[match.names.zip(match.captures)]
        end
      end

      def load_matchers
        { all: [{ match: /api\//,
                  index: "logstash-central-logging",
                  split: {
                             message: /(?<load_balancer_ip_address>(\d{1,3}\.){3}\d{1,3})\s[^\s]*\s.*(?<user_ip_address>(\d{1,3}\.){3}\d{1,3}).*\[(?<timestamp>.*)\]\s*"(?<request_domain>([^"]*))".*(?<request_method>(GET|POST|PUT|DELETE))\s*(?<request_path>[^.]*)\.(?<request_format>\w+)?(\?(?<request_query>([^\s]*)))[^"]*"\s+(?<response_code>\d{3}).*/,
                             request_path: [
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)\/affiliates\/(?<affiliate_id>[^\/]*)\/affiliate_campaigns/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)\/affiliate_campaigns/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)\/promo_numbers\/(?<promo_number>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)\/promo_numbers/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)\/ring_pools\/(?<ring_pool_id>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)\/ring_pools/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns\/(?<advertiser_campaign_id>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/advertiser_campaigns/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/users\/(?<user_id>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/users/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/affiliates\/(?<affiliate_id>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)\/affiliates/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/affiliates\/(?<affiliate_id>[^\/]*)/,
                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/affiliates/,

                                              /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/network/
                                           ]
                         }
                }]
        }
      end

      def load_indexes
        { "logstash-central-logging" => { api_version:              { type: "keyword" },
                                          timestamp:                { type: "date" },
                                          load_balancer_ip_address: { type: "ip" },
                                          user_ip_address:          { type: "ip" } }
        }
      end
    end
  end
end
