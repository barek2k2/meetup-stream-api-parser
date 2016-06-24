require './stream_client.rb'

redis_options = {:host => 'localhost',:port => 6379, :event_list => 'events'}

# Infinite loop to ensure reconnection automatically in case of any interruption
loop do
  begin
    stream_client = StreamClient.new('stream.meetup.com','/2/open_events',80,redis_options)
    stream_client.listen_and_save
  rescue

  end
end

