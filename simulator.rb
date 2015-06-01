class Simulator
  attr_accessor :events, :time

  def initialize
    @events = []
    @time = 0.0
  end

  def run_events
    @events.each do |event|
      @time = event.time
      event.run(self)
    end
  end

  def schedule(event)
    @events << event
  end

end
