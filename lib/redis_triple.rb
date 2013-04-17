require "redis_triple/version"

User = Struct.new(:id)
Board = Struct.new(:id)
Learning = Struct.new(:id)

def create_user
  User.new(rand(10000))
end

def create_board
  Board.new(rand(10000))
end

def create_learning
  Learning.new(rand(10000))
end

module RedisTriple
  class Base
    require 'redis'
    attr_reader :redis
    def initialize(redis=nil)
      @redis ||= Redis.new(db: 11)
    end
    
    def add(subject, predicate, object, timestamp)
      ts = timestamp.to_i
      d = redis.hget("#{to_id(object)}:#{predicate}", to_id(subject)).to_s.split('|')
      redis.pipelined do |r|
        r.hmset("#{to_id(object)}:#{predicate}", to_id(subject), (d << ts).join('|'))
        # reverse lookup
        r.zadd("#{to_id(subject)}:#{predicate}", ts, to_id(object))
      end
    end
    
    def to_id(obj)
      "#{obj.class}:#{obj.id}"
    end
  end
end
