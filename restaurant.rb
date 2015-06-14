require 'rails'
require './simulation.rb'
require './server.rb'
require './event.rb'
require './queue.rb'
require './events.rb'
require './generator.rb'
require './check_in_server.rb'
require './weight_server.rb'
require './payment_server.rb'
require './customer.rb'

class RestaurantSimulation < Simulation
  attr_accessor :check_in_queue, :weight_queue, :payment_queue,
                :customers, :stats, :payment_servers, :weight_servers, :check_in_servers

  def initialize(start_time, end_time, check_in_servers = 1, weight_servers = 1, payment_servers = 1)
    super(start_time, end_time)
    @customers = []
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

    @payment_servers = payment_servers
    @weight_servers = weight_servers
    @check_in_servers = check_in_servers


    start
  end

  def start
    @check_in_queue = Queue.new
    @check_in_servers.times do |time|
      @check_in_queue.servers << CheckInServer.new
    end

    @weight_queue = Queue.new
    @weight_servers.times do |time|
      @weight_queue.servers << WeightServer.new
    end

    @payment_queue = Queue.new
    @payment_servers.times do |time|
      @payment_queue.servers << PaymentServer.new
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


    # puts stats
    puts "CHECK IN QUEUE: #{check_in_queue.size}"

    puts "SERVERS SIZE"
    puts "CHECK IN #{@check_in_servers} : #{@check_in_queue.servers.collect {|x| x.id }.inspect}"
    puts "WEIGHT #{@weight_servers} : #{@weight_queue.servers.collect {|x| x.id }.inspect}"
    puts "PAYMENT #{@payment_servers} : #{@payment_queue.servers.collect {|x| x.id }.inspect}"
  end
end
