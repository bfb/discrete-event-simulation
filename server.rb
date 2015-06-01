class Server < Event
  attr_accessor :queue, :current

  def run(simulator)
    puts "Finished serving #{current.name} at time #{self.time}"
    @current = nil
    unless queue.isEmpty?
      customer = @queue.next
      schedule(simulator, customer)
    end
  end

  def isBusy?
    !current.nil?
  end

  def schedule(simulator, customer)
    if isBusy?
      puts "Error: server is busy!!!!!!"
      return
    end

    @current = customer
    # generate a random service time
    service_time = 10
    self.time = simulator.time + service_time

    simulator.schedule(self)
  end
end
