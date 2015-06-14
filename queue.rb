class Queue
  attr_accessor :members, :servers

  def initialize
    @members = []
    @servers = []
  end

  # insert a member
  def insert(member)
    @members << member
  end

  def next
    # removes the first member
    puts "REMOVE ELEMENT! #{@members.first}"
    puts "SIZE: #{members.size}"
    m = @members.shift
    puts "SIZE: #{members.size}"
    m
  end

  def size
    @members.size
  end

  def is_empty?
    @members.empty?
  end

  def lazy_server
    s=@servers.select {|x| !x.busy? }.sample
    puts "\n\nLAZY SERVER: #{s}\n\n"
    s
  end
end
