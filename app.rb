require './initializer.rb'
require 'sinatra'

class Time
  def time_to_f
    "#{self.hour}.#{self.min}#{self.sec}".to_f
  end
end

post '/run' do
  start_time = params[:simulation][:start_time].to_time
  end_time = params[:simulation][:end_time].to_time
  check_in_servers = params[:simulation][:check_in_servers].to_i
  weight_servers = params[:simulation][:weight_servers].to_i
  payment_servers = params[:simulation][:payment_servers].to_i
  lambda = params[:simulation][:lambda].to_f

  @simulation = RestaurantSimulation.new(lambda, start_time, end_time,
                check_in_servers, weight_servers, payment_servers)

  response = { customers: @simulation.stats[:customers], queues: {}, servers: {} }

  # compute all stats

  @simulation.stats[:queues].each do |key, queue|
    response[:queues][key] = []
    queue.each do |x, y|
      response[:queues][key] << { x: x, y: y }
    end
  end


  all = []
  @simulation.stats[:servers][:payment_servers].each do |k,server|
    all << server.keys
  end

  total_time = all.flatten.sort {|x,y| x <=> y }.last - start_time


  # calculate busy time for each server
  @simulation.stats[:servers].each do |key, servers|
    response[:servers][key] = {}
    servers.each do |id, values|
      response[:servers][key][id] = { pie: [], line: [] }

      previous = values.keys.first

      busy = 0
      start_interval = 0.0
      values.each do |x, y|
        response[:servers][key][id][:line] << { x: x, y: y }
        #
        # Data format:
        # x = time
        # y = 0 or 1
        if y != previous && y == 1
          start_interval = x
          previous = 1
        end

        if y != previous && y == 0
          interval = x - start_interval
          busy += interval
          previous = 0
        end

      end

      busy_percent = ((busy*100.0)/total_time).round(2)
      iddle_percent = 100 - busy_percent
      response[:servers][key][id][:pie] = [
        { y: busy_percent, indexLabel: "Busy #{busy_percent}%"},
        { y: iddle_percent, indexLabel: "Iddle #{iddle_percent}%"}
      ]

      queue_delay = {
        check_in_queue: 0,
        weight_queue: 0,
        payment_queue: 0
      }

      @simulation.customers.each do |customer|
        customer.stats.each do |queue, values|
          queue_delay[queue] += values[:departure_at] - values[:arrived_at]
        end
      end

      total_customers = @simulation.customers.size
      response[:queue_delay] = {
        check_in_queue: (queue_delay[:check_in_queue]/total_customers).round(2),
        weight_queue: (queue_delay[:weight_queue]/total_customers).round(2),
        payment_queue: (queue_delay[:payment_queue]/total_customers).round(2)
      }

    end
  end

  response.to_json
end


