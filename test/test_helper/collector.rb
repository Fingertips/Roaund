class Collector
  attr_reader :written
  def initialize
    @written = []
  end
  def write(message)
    @written << message
  end
  
  def puts(message)
    write("#{message}\n")
  end
end