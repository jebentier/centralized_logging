require 'bundler/setup'
Dir[File.join(__dir__, 'log_consumer/**/*.rb')].each { |file| require file }
