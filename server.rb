class Server
  attr_accessor :current, :id, :stats

  def initialize(id)
    @id = id
    @stats = {}
  end

  def busy?
    !@current.nil?
  end

  def iddle!
    @current = nil
  end

  def collect(event_time, status)
    @stats[event_time] = status
  end
end
