require "redis_triple/version"
module RedisTriple
  class Base
    require 'redis'
    attr_reader :redis
    def initialize(redis=nil)
      @redis = redis || Redis.new(db: 11)
    end
    
    # example: triple.add "User:1", "viewed", "Board:123"
    def add(subject, predicate, object, timestamp)
      ts = timestamp.to_i
      d = redis.hget("#{object}:#{predicate}", subject).to_s.split('|')
      redis.pipelined do |r|
        # multiple storage solutions so we do not have to perform wildcard searches across the key space
        
        # all the times this triple has happened per object/predicate/subject pair
        r.hmset("#{object}:#{predicate}", subject, (d << ts).join('|')) 
         # all the times this triple has happened
        r.sadd("#{subject}:#{predicate}:#{object}", ts)
        # all objects for this subject/predicate pair
        r.zadd("#{predicate}:#{subject}", ts, object)
        # all subjects for this predicate
        r.sadd predicate, subject
        # all activity for this subject
        r.zadd(subject, ts, "#{predicate}:#{object}")
      end
    end
    
    def remove(subject, predicate, object)
      redis.pipelined do |r|
        r.hdel("#{object}:#{predicate}", subject)
        r.zrem("#{predicate}:#{subject}", object)
      end
    end
  end
end
