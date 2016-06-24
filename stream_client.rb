require 'socket'
require 'redis'
require 'json'
require 'uri'

# Stream Client class for Stream API
class StreamClient
  # Initialize instance of StreamClient
  # * +host(String)+ - Host of the stream API like "stream.meetup.com"
  # * +path(String)+ - Additional path of stream API like "/2/open_events"
  # * +port(Integer)+ - Port of the stream API, default is 80
  #
  # ==== redis_options
  # Hash of Redis server
  # * +:host(String)+ - Redis Server host like "localhost or an IP"
  # * +:port(Integer)+ - Redis server port, default is 6379
  #
  # ==== stream_query_options
  # Hash of query parameter
  # * +:since_mtime(Integer)+ - Time in milliseconds like "(Date.today+10).strftime('%Q')"
  # More example of query parameters at http://www.meetup.com/meetup_api/docs/stream/2/open_events/
  def initialize(host,path,port=80, redis_options={},stream_query_options={})
    @host = host
    @path = path
    @path = @path + "?" + URI.encode(stream_query_options.map{|k,v| "#{k}=#{v}"}.join("&")) if stream_query_options.keys.any?
    @port = port    
    @redis ||= Redis.new(:host => redis_options[:host] || "localhost", :port => redis_options[:port] || 6379)
    @event_list = redis_options[:event_list]
  end

  # Listens socket and saves event name into redis database after gathering valid JSON response
  def listen_and_save
    socket = TCPSocket.new(@host,@port)
    socket.write "GET #{@path} HTTP/1.1\r\n"
    socket.write "Host: #{@host}\r\n"
    socket.write "\r\n"    
    captured_content = ""
    while line = socket.readline.chomp # used chomp to remove trailing newline         
    # concatenating line socket response to avoid broken JSON from socket
    captured_content = captured_content + line if line.length > 10
    captured_content = "" if !captured_content.start_with?('{"') 
      if result = valid_json?(captured_content)
         add_to_redis_list(result)
         captured_content = "" 
      end    
    end   
  end

  private
  def valid_json?(json)
    begin
      return JSON.parse(json)
    rescue JSON::ParserError => e
      return false
    end
  end

  # Adds event name into events list on Redis
  # * +captured_content+ - Valid JSON
  def add_to_redis_list(captured_content)
    begin
      @redis.rpush(@event_list,captured_content["name"])
      puts @redis.lrange(@event_list, 0, -1 )
    rescue Exception => e
      puts e.message
    end
  end

end
