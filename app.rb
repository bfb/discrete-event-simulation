require './restaurant.rb'
require 'sinatra'

post '/run' do
  puts "PARAMS => #{params.inspect}"

  start_time = Time.now
  end_time = Time.now + 5.minutes

  @simulation = RestaurantSimulation.new(start_time, end_time, 2, 4, 3)

  response = { queues: {}, servers: {} }

  @simulation.stats[:queues].each do |key, queue|
    response[:queues][key] = { x: queue.keys, y: queue.values }
  end

  @simulation.stats[:servers].each do |key, servers|
    response[:servers][key] = {}
    servers.each do |id, values|
      response[:servers][key][id] = { x: values.keys, y: values.values }
    end
  end
  puts "\n\nSTATS: #{@simulation.stats}\n\n"

  # check_in_queue.sort {|x, y| x.first <=> y.first }.to_json
  # check_in_queue.to_json
  puts response
  response.to_json
end
