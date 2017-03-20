#!/bin/bash

RANDOM=$$$(date +%s)
API_VERSIONS=("2016-10-01" "2017-02-01" "2015-03-22" "2012-01-14" "2009-01-01")
RESPONSE_CODES=("200" "201" "202" "204" "302" "400" "404" "500")
REQUEST_METHODS=("GET" "POST" "PUT" "DELETE")

while true; do
  api_version=${API_VERSIONS[$RANDOM % ${#API_VERSIONS[@]} ]}
  ip_tuple=$(((RANDOM%254)+1))
  network_id=$(((RANDOM%254)+1))
  advertiser_id=$(((RANDOM%254)+1))
  advertiser_campaign_id=$(((RANDOM%254)+1))
  response_code=${RESPONSE_CODES[$RANDOM % ${#RESPONSE_CODES[@]} ]}
  response_time=$(((RANDOM%200)+50))
  request_method=${REQUEST_METHODS[$RANDOM % ${#REQUEST_METHODS[@]} ]}

  echo "10.0.2.28 9443 - 38.96.190.$ip_tuple [$(date +%Y-%m-%dT%H:%M:%S)]  \"invoca.net\" \"$request_method /api/$api_version/$network_id/advertisers/$advertiser_id/advertiser_campaigns.json?oauth_token=SgsggHhszUgp2JZIO_KmjtDZJv18-Mxz HTTP/1.1\" $response_code 6756 \"-\" \"-\" \"-\" \"-\" 0.798 0.798 ." >> /var/log/test.log
  sleep 1
done
