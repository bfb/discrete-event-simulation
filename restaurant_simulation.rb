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
    generator.time = @time + 30.seconds
    schedule(generator)

    run_events

    build_stats


    # puts "TOTAL CUSTOMERS => #{@customers.size}"
    # # puts stats
    # puts "CHECK IN QUEUE: #{check_in_queue.size}"

    # puts "SERVERS SIZE"
    # puts "CHECK IN #{@check_in_servers} : #{@check_in_queue.servers.collect {|x| x.id }.inspect}"
    # puts "WEIGHT #{@weight_servers} : #{@weight_queue.servers.collect {|x| x.id }.inspect}"
    # puts "PAYMENT #{@payment_servers} : #{@payment_queue.servers.collect {|x| x.id }.inspect}"
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
