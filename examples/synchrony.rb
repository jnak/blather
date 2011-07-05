require 'blather/client'

# Use only EM Synchrony compatible libraries, otherwise you'll lose the sync style
require 'mysql2/em_fiber'
require 'em-synchrony/em-redis'

setup 'echo@jabber.local/ping', 'echo'

# This is not perfect as some stanzas may arrive before the pools are created
# But redis seems to hang otherwise 
# redis workaround: define redis in EM.next_tick {Fiber.new {...}.resume} block

when_ready do  
  @redis = EventMachine::Synchrony::ConnectionPool.new(size: 10) do
    EM::P::Redis.connect 
  end
  @mysql = EventMachine::Synchrony::ConnectionPool.new(size: 10) do
    Mysql2::EM::Fiber::Client.new
  end
end

# Synchronous ruby style, but everything is non-blocking
# Stanzas are processed asynchronously: be carful with race conditions

status :available? do |s|
  r = Time.now
  puts r
  @redis.set "r", "Dude ! Redis with no callbacks"
  p "nj"
  res = @redis.get "r" 
  puts "#{res}"
  
  puts Time.now
  rez = @mysql.query "SELECT sleep(3)"
  puts "3 secs later " + Time.now.to_s
end
