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
    if busy?
      puts "Error: server is busy!!!!!!"
      return
    end

    @current = customer
    # generate a random service time
    gen = Croupier::Distributions::Normal.new(mean: 1.0, std: 0.3).generate_number
    # service_time = 1.seconds
    service_time = gen.seconds

    # self.time = simulation.time + service_time

    done = CheckInDone.new(simulation.time + service_time, customer)
    done.server = self

    simulation.schedule(done)
    # @current = nil
  end
end
