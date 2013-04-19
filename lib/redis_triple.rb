require "redis_triple/version"
module RedisTriple
  class Base
    require 'redis'
    attr_reader :redis
    def initialize(redis=nil)
      @redis ||= Redis.new(db: 11)
    end
    
    def add(subject, predicate, object, timestamp)
      ts = timestamp.to_i
      d = redis.hget("#{object}:#{predicate}", subject).to_s.split('|')
      redis.pipelined do |r|
        r.hmset("#{object}:#{predicate}", subject, (d << ts).join('|'))
        # reverse lookup
        r.zadd("#{predicate}:#{subject}", ts, object)
      end
    end
    
    def remove(subject, predicate, object)
      redis.pipelined do |r|
        r.hdel("#{object}:#{predicate}", subject)
        # reverse lookup
        r.zrem("#{predicate}:#{subject}", object)
      end
    end
  end
end
