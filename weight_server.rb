class WeightServer < Server
  def execute(simulation, customer)
    puts "Pesando #{customer.name}"
    if busy?
      puts "Error: server is busy!!!!!!"
      return
    end

    @current = customer
    # generate a random service time
    service_time = 20.seconds
    # self.time = simulation.time + service_time

    done = WeightDone.new(simulation.time + service_time, customer)
    simulation.schedule(done)
    # @current = nil
  end
end
