class CheckInStart < Event
  def run(simulation)
    # puts "SIMULATION: #{simulation} TIME: #{simulation.time}"
    server = simulation.check_in_queue.lazy_server

    simulation.stats[:queues][:check_in_queue][self.time] = simulation.check_in_queue.size

    if server.nil?
      # puts "#{self.customer.name} go to queue"
      simulation.check_in_queue.insert(self.customer)
    else
      server.execute(simulation, self.customer)
    end
  end
end

class CheckInDone < Event
  def run(simulation)
    simulation.stats[:queues][:check_in_queue][self.time] = simulation.check_in_queue.size

    # set server current to nil
    server = simulation.check_in_queue.server
    server.current = nil

    puts "#{@customer.name} atendido."
    buffet_time = 5.minutes
    weight = WeightStart.new(simulation.time + buffet_time, customer)
    simulation.schedule(weight)

    # server = simulation.check_in_queue.lazy_server
    if @customer = simulation.check_in_queue.next
      server.execute(simulation, @customer)
    end
  end
end

class WeightStart < Event
  def run(simulation)
    # puts "SIMULATION: #{simulation} TIME: #{simulation.time}"
    server = simulation.weight_queue.lazy_server

    simulation.stats[:queues][:weight_queue][self.time] = simulation.weight_queue.size

    if server.nil?
      # puts "#{self.customer.name} go to queue"
      simulation.weight_queue.insert(self.customer)
    else
      server.execute(simulation, self.customer)
    end
  end
end

class WeightDone < Event
  def run(simulation)
    simulation.stats[:queues][:weight_queue][self.time] = simulation.weight_queue.size

    # set server current to nil
    server = simulation.weight_queue.server
    server.current = nil

    puts "#{@customer.name} atendido."
    lunch_time = 20.minutes
    payment = PaymentStart.new(simulation.time + lunch_time, customer)
    simulation.schedule(payment)

    # server = simulation.check_in_queue.lazy_server
    if @customer = simulation.weight_queue.next
      server.execute(simulation, @customer)
    end
  end
end

class PaymentStart < Event
  def run(simulation)
    # puts "SIMULATION: #{simulation} TIME: #{simulation.time}"
    server = simulation.payment_queue.lazy_server

    simulation.stats[:queues][:payment_queue][self.time] = simulation.payment_queue.size

    if server.nil?
      # puts "#{self.customer.name} go to queue"
      simulation.payment_queue.insert(self.customer)
    else
      server.execute(simulation, self.customer)
    end
  end
end

class PaymentDone < Event
  def run(simulation)
    simulation.stats[:queues][:payment_queue][self.time] = simulation.payment_queue.size

    # set server current to nil
    server = simulation.payment_queue.server
    server.current = nil

    puts "#{@customer.name} atendido."

    # server = simulation.check_in_queue.lazy_server
    if @customer = simulation.payment_queue.next
      server.execute(simulation, @customer)
    end
  end
end
