require 'csv'

#==================================================================================================#
#======================================= Global Methods ===========================================#
#==================================================================================================#

def parse_file(file)
  temp = CSV.parse(File.read(File.join(File.dirname(__FILE__), file)))
end

def sum
  sum = 0
  self.each { |num| sum += num.to_i }
  return sum
end

#==================================================================================================#
#====================================== Class Definitions =========================================#
#==================================================================================================#

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

#==================================================================================================#
#==================================================================================================#

class ScoreCard < Hash
  attr_accessor :course, :score_term, :player_output, :final_string

  def initialize
    @score_term = ["Par", "Bogey", "Double Boge", "Triple Boge", "Eagle", "Birdie"]
    @player_output = {}
    @final_string = ""
  end

#======================================== Set File Data ===========================================#

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

#======================================== Calculate Scores ========================================#

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
    return 'Ace' if hole_in_one?(self[player][hole - 1])
    return @score_term[hole_sc] unless hole_sc > 3
    return "Superbogey"
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

#========================================= Output Scores ==========================================#

  def output_hole_score(hole, player)
    score_t = return_score_term(hole, player)
    return "Hole #{hole}: #{self[player][hole-1]} - #{score_t}"
  end

  def output_scores_per_player
    self.each do |player, scores_array|
      @player_output[player] = []
      (1..18).each do |hole|
        @player_output[player].push(output_hole_score(hole, player))
      end
    end
  end

  def final_output
    output_scores_per_player
    add_leaderboard_to_string
    @player_output.each do |player, scores_array|
      add_player_name_to_string(player)
      add_scores_to_string(scores_array)
      add_totals_to_string(player)
    end
  end

  def add_leaderboard_to_string
    leaderboard = calculate_leaderboard
    @final_string << "==Leaderboard\n"
    leaderboard.each do |player, score|
      @final_string << "#{score[0]}, #{score[1]}: #{player}\n"
    end
    @final_string << "\n"
  end

  def calculate_leaderboard
    leaderboard = {}
    self.each do |player, scores|
      total = total_score(player) + @course.par
      leaderboard[player] = [total, total_score(player)]
    end
    return leaderboard.sort_by { |player, score| score }
  end

  def add_player_name_to_string(player)
    @final_string << "==#{player}\n"
  end

  def add_scores_to_string(scores_array)
    scores_array.each do |score|
      @final_string << "#{score}\n"
    end
  end

  def add_totals_to_string(player)
    total = total_score(player) + @course.par
    @final_string << "\nTotal Score: #{total}\n"
    @final_string << "#{total_score(player)}\n\n"
  end

#========================================= Write to CSV ===========================================#

  def write_to_csv
    File.open('final.txt', 'w') { |file| file << final_string }
  end
end

#==================================================================================================#
#==================================================================================================#
