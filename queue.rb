class Queue
  attr_accessor :members, :servers

  def initialize
    @members = []
    @servers = []
  end

  # insert a member
  # checks if server is available
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
    @servers.select {|x| !x.busy? }.first
  end
end
