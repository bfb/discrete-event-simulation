class CheckInServer < Server
  # def run(simulator)
  #   puts "Finished serving #{current.name} at time #{self.time}"
  #   @current = nil
  #   unless queue.isEmpty?
  #     customer = @queue.next
  #     schedule(simulator, customer)
  #   end
  # end

  def execute(simulation, customer)
    puts "Atendendo #{customer.name}"
    if busy?
      puts "Error: server is busy!!!!!!"
      return
    end

    @current = customer
    # generate a random service time
    service_time = 10.seconds
    # self.time = simulation.time + service_time

    done = CheckInDone.new(simulation.time + service_time, customer)
    done.server = self

    simulation.schedule(done)
    # @current = nil
  end
end
