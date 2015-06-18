class CheckInServer < Server

  def execute(simulation, customer)
    if busy?
      puts "Error: server is busy!"
      return
    end

    @current = customer
    # generate a random service time
    gen = Croupier::Distributions::Normal.new(mean: 1.0, std: 0.3).generate_number
    service_time = gen.seconds

    done = CheckInDone.new(simulation.time + service_time, customer)
    done.server = self

    simulation.schedule(done)
  end
end
