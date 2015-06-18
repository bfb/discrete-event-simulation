class WeightServer < Server
  def execute(simulation, customer)
    if busy?
      puts "Error: server is busy!"
      return
    end

    @current = customer
    # generate a random service time
    service_time = Croupier::Distributions::Normal.new(mean: 9.37, std: 1.44).generate_number.seconds

    done = WeightDone.new(simulation.time + service_time, customer)
    done.server = self

    simulation.schedule(done)
    # @current = nil
  end
end
