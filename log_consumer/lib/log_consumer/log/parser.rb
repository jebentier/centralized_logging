module LogConsumer
  module Log
    class Parser
      attr_reader :request_regex, :path_regex

      def initialize
        @request_regex = /(?<ip_address>(\d{1,3}\.){3}\d{1,3}).*\[(?<timestamp>.*)\].*(?<request_method>(GET|POST|PUT|DELETE))\s*(?<request_path>[^.]*)\.(?<request_format>\w+).*(?<response_code>\d{3}).*(?<response_time_ms>\d+)\s*"(?<referrer>[^"]*)"\s"(?<requesting_client>[^"]*)"/
        @path_regex    = /\/api\/(?<api_version>[^\/]*)\/(?<network_id>\d+)\/advertisers\/(?<advertiser_id>\d+)\/advertiser_campaigns\/(?<advertiser_campaign_id>\d+)/
      end

      def parse(log)
        match = log.match(request_regex)
        path_match = match["request_path"].match(path_regex)

        { "logstash-central_logging" => [{ timestamp:              match["timestamp"],
                                           ip_address:             match["ip_address"],
                                           source:                 "front-end-1",
                                           request_method:         match["request_method"],
                                           request_path:           match["request_path"],
                                           network_id:             path_match["network_id"].to_i,
                                           advertiser_id:          path_match["advertiser_id"].to_i,
                                           advertiser_campaign_id: path_match["advertiser_campaign_id"].to_i,
                                           api_version:            path_match["api_version"],
                                           request_format:         match["request_format"],
                                           response_code:          match["response_code"].to_i,
                                           response_time_ms:       match["response_time_ms"].to_i,
                                           referrer:               match["referrer"],
                                           requesting_client:      match["requesting_client"],
                                           message:                log }] }
      end
    end
  end
end
