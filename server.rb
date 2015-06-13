require 'secure_random'

class Server
  attr_accessor :current, :id

  def initialize
    self.id = SecureRandom.uuid
  end

  def busy?
    !current.nil?
  end
end
