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
                      if regex.is_a?(Array) # regex is an ordered list of highest -> lowest precedent patterns to match. Take the first that matches.
                        regex.find do |pattern|
                          if match = thing_to_split.match(regex)
                            body.merge!(Hash[ match.names.zip( match.captures ) ])
                          end
                          !!match
                        end
                      else  # regex is a single pattern, match it against thing_to_split.
                        match = thing_to_split.match(regex)
                        body.merge!(Hash[ match.names.zip( match.captures ) ])
                      end
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
                             message: /(?<load_balancer_ip_address>(\d{1,3}\.){3}\d{1,3})\s[^\s]*\s.*(?<user_ip_address>(\d{1,3}\.){3}\d{1,3}).*\[(?<timestamp>.*)\]\s*"(?<request_domain>([^"]*))".*(?<request_method>(GET|POST|PUT|DELETE))\s*(?<request_path>[^.]*)\.(?<request_format>\w+)?(\?(?<request_query>([^\s]*)))[^"]*"\s+(?<response_code>\d{3}).*/,
                             request_paths: [
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
        { "logstash-central-logging" => { api_version: { type: "keyword" },
                                          timestamp:   { type: "date" } }
        }
      end
    end
  end
end
