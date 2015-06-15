class Queue
  attr_accessor :members, :servers, :stats

  def initialize
    @members = []
    @servers = []
    @stats = {}
  end

  # insert a member
  def insert(member)
    @members << member
  end

  def next
    # removes the first member
    @members.shift
  end

  def size
    @members.size
  end

  def is_empty?
    @members.empty?
  end

  def lazy_server
    @servers.select {|x| !x.busy? }.sample
  end

  def done?
    @servers.select {|x| !x.busy? } == @servers.size
  end

  def collect(event_time)
    @stats[event_time] = @members.size
  end

end
