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
#=====================================================================================#

class ScoreCard < Hash
  attr_accessor :course, :score_term

  def initialize
    @score_term = ["par", "bogey", "double boge", "triple boge", "eagle", "birdie"]
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

  def hole_score(hole, player)
    index = hole - 1
    hole_score = self[player][index] - self.course[index]
    return hole_score
  end

  def total_score(player)
    total_score = 0
    (1..18).each { |hole| total_score += hole_score(hole, player) }
    return total_score
  end

  def return_score_term(hole, player)
    hole_sc = hole_score(hole, player)
    return 'ace' if hole_in_one?(self[player][hole - 1])
    return @score_term[hole_sc] unless hole_sc > 3
    return "superbogey"
  end

  def all_scores
    total_scores = {}
    self.each do |key, value|
      total_scores[key] = total_score(key)
    end
    return total_scores
  end

  def hole_in_one?(hole)
    return true if hole == 1
  end
end

#=====================================================================================#
#=====================================================================================#
