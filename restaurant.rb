require './simulator.rb'
require './event.rb'
require './queue.rb'
require './generator.rb'
require './server.rb'
require './customer.rb'

class RestaurantSimulator < Simulator
  def initialize
    super
    start
  end

  def start
    queue = Queue.new
    generator = Generator.new
    server = Server.new

    generator.queue = queue
    queue.server = server
    server.queue = queue

    # schedule generator
    generator.time = 0.0
    schedule(generator)

    run_events
  end

end

RestaurantSimulator.new
