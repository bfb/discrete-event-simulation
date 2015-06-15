class CheckInStart < Event
  def run(simulation)
    simulation.check_in_queue.collect(@time)

    @customer.collect(:check_in_queue, :arrived_at, @time)
    server = simulation.check_in_queue.lazy_server

    if server.nil?
      simulation.check_in_queue.insert(@customer)
    else
      server.collect(@time, 1)

      server.execute(simulation, @customer)
    end
  end
end

class CheckInDone < Event
  attr_accessor :server

  def run(simulation)
    simulation.check_in_queue.collect(@time)
    @customer.collect(:check_in_queue, :departure_at, @time)

    @server.iddle!

    buffet_time = Croupier::Distributions::Normal.new(mean: 17.34, std: 0.30).generate_number.minutes
    weight = WeightStart.new(simulation.time + buffet_time, customer)
    simulation.schedule(weight)

    if @customer = simulation.check_in_queue.next
      simulation.check_in_queue.collect(@time)
      @server.execute(simulation, @customer)
    else
      @server.collect(@time, 0)
    end
  end
end

class WeightStart < Event
  def run(simulation)
    server = simulation.weight_queue.lazy_server

    simulation.weight_queue.collect(@time)
    @customer.collect(:weight_queue, :arrived_at, @time)

    if server.nil?
      simulation.weight_queue.insert(@customer)
    else
      server.collect(@time, 1)

      server.execute(simulation, @customer)
    end
  end
end

class WeightDone < Event
  attr_accessor :server

  def run(simulation)
    simulation.weight_queue.collect(@time)
    @customer.collect(:weight_queue, :departure_at, @time)

    @server.iddle!

    lunch_time = Croupier::Distributions::Normal.new(mean: 22.40, std: 4.44).generate_number.minutes
    payment = PaymentStart.new(simulation.time + lunch_time, customer)
    simulation.schedule(payment)

    if @customer = simulation.weight_queue.next
      @server.execute(simulation, @customer)
    else
      @server.collect(@time, 0)
    end
  end
end

class PaymentStart < Event
  def run(simulation)
    server = simulation.payment_queue.lazy_server

    simulation.payment_queue.collect(@time)
    @customer.collect(:payment_queue, :arrived_at, @time)

    if server.nil?
      simulation.payment_queue.insert(@customer)
    else
      server.collect(@time, 1)

      server.execute(simulation, @customer)
    end
  end
end

class PaymentDone < Event
  attr_accessor :server

  def run(simulation)
    simulation.payment_queue.collect(@time)
    @customer.collect(:payment_queue, :departure_at, @time)

    @server.iddle!

    if @customer = simulation.payment_queue.next
      @server.execute(simulation, @customer)
    else
      @server.collect(@time, 0)
    end
  end
end
