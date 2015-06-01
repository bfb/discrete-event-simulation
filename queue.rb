class Queue
  attr_accessor :members, :server

  def initialize()
    @members = []
    # @server = server
  end

  # insert a member
  # checks if server is available
  def insert(simulator, member)
    if @server.isBusy?
      @members << member
    else
      @server.schedule(simulator, member)
    end
  end

  def next
    # removes the first member
    @members.shift
  end

  def size
    @members.size
  end

  def isEmpty?
    @members.empty?
  end
end
