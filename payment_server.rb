class PaymentServer < Server
  def execute(simulation, customer)
    if busy?
      puts "Error: server is busy!"
      return
    end

    @current = customer
    # generate a random service time
    service_time = Croupier::Distributions::Normal.new(mean: 23.36, std: 4.79).generate_number.seconds

    done = PaymentDone.new(simulation.time + service_time, customer)
    done.server = self

    simulation.schedule(done)
  end
end
