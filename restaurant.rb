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

  def initialize(start_time, end_time, payment_servers, weight_servers, check_in_servers)
    super(start_time, end_time)
    @customers = []
    @stats = {
      queues: {
        check_in_queue: {},
        weight_queue: {},
        payment_queue: {}
      },
      servers: {
        check_in_server: {},
        weight_server: {},
        payment_server: {}
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

    end

    @check_in_server = CheckInServer.new

    @check_in_queue.server = check_in_server

    weight_server = WeightServer.new
    @weight_queue = Queue.new
    @weight_queue.server = weight_server

    payment_server = PaymentServer.new
    @payment_queue = Queue.new
    @payment_queue.server = payment_server


    generator = Generator.new
    # generator.simulation = self

    # generator.queue = queue
    # queue.server = server
    # server.queue = queue

    # schedule generator
    generator.time = @time + 30.seconds
    schedule(generator)

    run_events

    puts stats
  end
end

RestaurantSimulation.new(Time.now, Time.now + 2.minutes)
