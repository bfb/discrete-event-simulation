class Simulation
  attr_accessor :events, :time, :end_time

  def initialize(start_time, end_time)
    @events = []
    @time = start_time
    @end_time = end_time
  end

  def run_events
    while !@events.empty?
      run_event
    end
  end

  def run_event
    event = @events.shift

    @time = event.time
    event.run(self)
  end

  def schedule(event)
    @events << event
    @events.sort! {|a,b| a.time <=> b.time }
  end

end
