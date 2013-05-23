require 'csv'

class HoleLayout < Array

  attr_accessor :par

  def load_file(file)
    hole_pars = (CSV.parse(File.read(File.join(File.dirname(__FILE__), file)))).flatten
    hole_pars.each do |par|
      self.push(par.to_i)
    end
  end

  def sum
    sum = 0
    self.each { |num| sum += num }
    return sum
  end

  def par
    sum
  end

end


