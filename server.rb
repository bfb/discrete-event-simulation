require 'securerandom'

class Server
  attr_accessor :current, :id

  def initialize
    @id = SecureRandom.uuid
  end

  def busy?
    !@current.nil?
  end

  def iddle!
    @current = nil
  end
end
