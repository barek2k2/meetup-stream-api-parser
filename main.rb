require './stream_client.rb'
require 'date'

redis_options = {:host => 'localhost',:port => 6379, :event_list => 'events'}
stream_query_options = {}

# Infinite loop to ensure reconnection automatically in case of any interruption
loop do
  begin
    stream_client = StreamClient.new('stream.meetup.com','/2/open_events',80,redis_options,stream_query_options)
    stream_client.listen_and_save
  rescue Exception => e
    puts "Interrupted/Error because of :: #{e.message}"
  end
end

