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
    # puts  "EVENTS: #{@events.collect {|x| [x.class.name, x.time.strftime('%H:%M:%S')] }.inspect}"
    event = @events.shift

    # if event.class == Generator
    #   puts "=> RUNNING #{event.class} AT #{event.time}"
    # else
    #   puts "=> RUNNING #{event.class} AT #{event.time} CUSTOMER #{event.customer.name}"
    # end

    @time = event.time
    event.run(self)
  end

  def schedule(event)
    @events << event
    @events.sort! {|a,b| a.time <=> b.time }
  end

end
