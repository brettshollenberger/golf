require 'csv'

#=====================================================================================#
#================================= Global Methods ====================================#
#=====================================================================================#

def parse_file(file)
  temp = CSV.parse(File.read(File.join(File.dirname(__FILE__), file)))
end

def sum
  sum = 0
  self.each { |num| sum += num }
  return sum
end

#=====================================================================================#
#================================ Class Definitions ==================================#
#=====================================================================================#

class HoleLayout < Array
  attr_accessor :par

  def load_file(file)
    hole_pars = parse_file(file).flatten
    hole_pars.each { |par| self.push(par.to_i) }
  end

  def par
    sum
  end
end

#=====================================================================================#

class ScoreCard < Hash
  attr_accessor :course, :score_term

  def initialize
    @score_term = ["par", "bogey", "ace", "eagle", "birdie"]
  end


  def load_file(file)
    array = parse_file(file)
    make_individual_scorecards(array)
    scores_to_i
  end

  def make_individual_scorecards(array)
    array.each { |sub_array| self[sub_array[0]] = sub_array[1..-1] }
  end

  def scores_to_i
    self.each do |key, array|
      numerical_array = []
      array.each do |num|
        numerical_array.push(num.to_i)
      end
      self[key] = numerical_array
    end
  end

  def load_course(file)
    @course = HoleLayout.new()
    @course.load_file(file)
  end

  def deviation(hole, player)
    index = hole - 1
    if self[player][index] == 1
      score = self[player][index] - self.course[index]
      ace = true
      return score, ace
    elsif
      score = self[player][index] - self.course[index]
      ace = false
      return score, ace
    end
  end

  def score(deviation, ace)
    if deviation > 1
      times = deviation - 1
      return "#{times}x bogey"
    elsif ace == true
      return @score_term[-3]
    else
      return @score_term[deviation]
    end
  end

  def total_score(player)
    total_score = 0
    (1..18).each do |hole|
      hole_score, ace = deviation(hole, player)
      total_score += hole_score
    end
    return total_score
  end

end
