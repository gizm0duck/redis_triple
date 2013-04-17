require 'redis_triple'

triple = RedisTriple::Base.new
triple.redis.flushdb
filename = File.join(File.dirname(__FILE__), "board_views.csv")
File.open(filename).each_line do |l|
  bid, guid, ts = l.split(",")
  board = Board.new(bid)
  user = User.new(guid)
  triple.add(user, 'views', board, ts)
end

uid = '491e5a60-61b0-0130-26ab-123139242bec'
puts "*"*50
puts "All boards user '#{uid}' has visited and the times at which this occurred"
puts "*"*50
boards = triple.redis.zrevrange "User:#{uid}:views", 0, -1
boards.each do |bid|
  times = triple.redis.hget("#{bid}:views", "User:#{uid}").split('|').map{|t| Time.at(t.to_i).strftime("%A, %b %d") }
  puts "#{bid} viewed #{times.size} by this user - #{times.join(', ')}"
  total_views = triple.redis.hgetall("#{bid}:views").inject(0){|i, (k,v)| i += v.split('|').size}
  puts "^ has been viewed #{total_views} by all users"
end


