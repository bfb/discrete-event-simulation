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
    event = @events.shift

    @time = event.time
    event.run(self)
  end

  def schedule(event)
    @events << event
    @events.sort! {|a,b| a.time <=> b.time }
  end

end

class RestaurantSimulation < Simulation
  attr_accessor :rate, :check_in_queue, :weight_queue, :payment_queue,
                :customers, :stats, :payment_servers, :weight_servers, :check_in_servers

  def initialize(rate, start_time, end_time, check_in_servers = 1, weight_servers = 1, payment_servers = 1)
    super(start_time, end_time)
    @customers = []
    @payment_servers = payment_servers
    @weight_servers = weight_servers
    @check_in_servers = check_in_servers
    @rate = rate

    start
  end

  def start
    @check_in_queue = Queue.new
    @check_in_servers.times do |time|
      @check_in_queue.servers << CheckInServer.new(time)
    end

    @weight_queue = Queue.new
    @weight_servers.times do |time|
      @weight_queue.servers << WeightServer.new(time)
    end

    @payment_queue = Queue.new
    @payment_servers.times do |time|
      @payment_queue.servers << PaymentServer.new(time)
    end

    generator = Generator.new
    # generator.simulation = self

    # generator.queue = queue
    # queue.server = server
    # server.queue = queue

    # schedule generator
    generator.time = @time + 30.seconds
    schedule(generator)

    run_events

    build_stats
  end

  def build_stats
    @stats = {
      queues: {
        check_in_queue: {},
        weight_queue: {},
        payment_queue: {}
      },
      servers: {
        check_in_servers: {},
        weight_servers: {},
        payment_servers: {}
      }
    }

    # collect queue stats
    @stats[:queues][:check_in_queue] = @check_in_queue.stats
    @stats[:queues][:weight_queue] = @weight_queue.stats
    @stats[:queues][:payment_queue] = @payment_queue.stats

    # collect check in servers stats
    @check_in_queue.servers.each do |server|
      @stats[:servers][:check_in_servers][server.id] = server.stats
    end

    # collect weight servers stats
    @weight_queue.servers.each do |server|
      @stats[:servers][:weight_servers][server.id] = server.stats
    end

    # collect payment servers stats
    @payment_queue.servers.each do |server|
      @stats[:servers][:payment_servers][server.id] = server.stats
    end

    # total customers
    @stats[:customers] = @customers.size
  end
end

class Customer
  attr_accessor :stats, :name

  def initialize
    @name = Faker::Name.name
    @stats = { check_in_queue: {}, payment_queue: {}, weight_queue: {} }
  end

  def collect(queue, action, event_time)
    @stats[queue][action] = event_time
  end
end


class Event
  attr_accessor :time, :customer

  def initialize(time, customer)
    self.time = time
    self.customer = customer
  end
end

class Generator < Event
  attr_accessor :total
  def initialize
    self.time = 0.0
  end

  def run(simulation)
    self.time = self.time + 10.seconds
    gen = Croupier::Distributions::Poisson.new(lambda: simulation.rate).generate_number

    gen.times do |i|
      customer = Customer.new
      simulation.customers << customer

      check_in = CheckInStart.new(self.time, customer)
      simulation.schedule(check_in)
    end

    simulation.schedule(self) if simulation.end_time >= self.time
  end
end


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

class Queue
  attr_accessor :members, :servers, :stats

  def initialize
    @members = []
    @servers = []
    @stats = {}
  end

  # insert a member
  def insert(member)
    @members << member
  end

  def next
    # removes the first member
    @members.shift
  end

  def size
    @members.size
  end

  def is_empty?
    @members.empty?
  end

  def lazy_server
    @servers.select {|x| !x.busy? }.sample
  end

  def done?
    @servers.select {|x| !x.busy? } == @servers.size
  end

  def collect(event_time)
    @stats[event_time] = @members.size
  end

end

class Server
  attr_accessor :current, :id, :stats

  def initialize(id)
    @id = id
    @stats = {}
  end

  def busy?
    !@current.nil?
  end

  def iddle!
    @current = nil
  end

  def collect(event_time, status)
    @stats[event_time] = status
  end
end

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
  end
end

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
