require 'rspec'
require_relative '../lib/golf.rb'

describe HoleLayout do
  context "Loading a course layout" do
    let(:correct_layout) { HoleLayout.new().push(3, 4, 5, 3, 4, 5, 4, 4, 5, 3, 4, 5, 3, 3, 4, 5, 3, 3) }
    let(:empty_layout) { HoleLayout.new() }
    let(:example_course_file) { 'example_pars.csv' }

    it "calculates the par for the course" do
      expect(correct_layout.par).to eql(70)
    end

    it "loads a CSV that contains the par per hole for a particular course" do
      empty_layout.load_file(example_course_file)
      expect(empty_layout.par).to eql(70)
    end
  end
end

describe ScoreCard do

  let(:empty_card) { ScoreCard.new() }
  let(:example_scores_file) { 'example_scores.csv' }
  let(:score_card) { ScoreCard.new().load_file('example_scores.csv') }
  let(:empty_layout) { HoleLayout.new() }
  let(:example_course_file) { 'example_pars.csv' }

  before(:each) do
    score_card.load_course(example_course_file)
  end

  context "Loading player scores and hole layout" do
    it "loads a CSV of player scores" do
      empty_card.load_file(example_scores_file)
      expect(empty_card).to be_kind_of(Hash)
      expect(empty_card['Woods']).to be_kind_of(Array)
      expect(empty_card['Woods']).to eql([1, 4, 4, 3, 2, 6, 6, 7, 9, 1, 1, 1, 3, 3, 4, 5, 3, 3])
    end

    it "loads a Hole Layout" do
      expect(score_card.course).to eql([3, 4, 5, 3, 4, 5, 4, 4, 5, 3, 4, 5, 3, 3, 4, 5, 3, 3])
    end
  end

  context "Calculating scores for each hole, player, and round" do
    it "can tell par of an individual hole" do
      expect(score_card.course[0]).to eql(3)
    end

    it "loads all the scores of an individual player" do
      expect(score_card['Woods'][0]).to eql(1)
      expect(score_card['Woods'][1]).to eql(4)
    end

    it "tells a player's deviation from par for an individual hole" do
      expect(score_card.hole_score(1, 'Woods')).to eql(-2)
      expect(score_card.hole_score(2, 'Woods')).to eql(0)
    end

    it "calculates a player's total score" do
      expect(score_card.total_score('Woods')).to eql(-4)
    end

    it "returns the total scores for all players" do
      expect(score_card.all_scores).to include("Woods" => -4)
    end

    it "gives a player an ace for a hole-in-one" do
      expect(score_card.return_score_term(1, "Woods")).to eql("Ace")
    end

    it "gives a player a par if they shoot par for the course" do
      expect(score_card.return_score_term(2, "Woods")).to eql("Par")
    end

    it "gives a player a birdie if they shoot one under par" do
      expect(score_card.return_score_term(3, "Woods")).to eql("Birdie")
    end

    it "gives a player an eagle if they shoot two under par" do
      expect(score_card.return_score_term(5, "Woods")).to eql("Eagle")
    end

    it "gives a player a bogey if they shoot one over par" do
      expect(score_card.return_score_term(6, "Woods")).to eql("Bogey")
    end

    it "gives a player a double boge if they shoot two over par" do
      expect(score_card.return_score_term(7, "Woods")).to eql("Double Boge")
    end

    it "gives a player a triple boge if they shoot three over par" do
      expect(score_card.return_score_term(8, "Woods")).to eql("Triple Boge")
    end

    it "gives a player a superbogey if a player shoots any higher than three over par" do
      expect(score_card.return_score_term(9, "Woods")).to eql("Superbogey")
    end
  end

  context "Outputting scores" do
    it "outputs single hole data for a player" do
      expect(score_card.output_hole_score(1, "Woods")).to eql("Hole 1: 1 - Ace")
    end

    it "outputs all scores for a player" do
      score_card.output_scores_per_player
      expect(score_card.player_output).to include("Woods" => ["Hole 1: 1 - Ace",
        "Hole 2: 4 - Par", "Hole 3: 4 - Birdie", "Hole 4: 3 - Par", "Hole 5: 2 - Eagle",
        "Hole 6: 6 - Bogey", "Hole 7: 6 - Double Boge", "Hole 8: 7 - Triple Boge", "Hole 9: 9 - Superbogey",
        "Hole 10: 1 - Ace", "Hole 11: 1 - Ace", "Hole 12: 1 - Ace", "Hole 13: 3 - Par", "Hole 14: 3 - Par",
        "Hole 15: 4 - Par", "Hole 16: 5 - Par", "Hole 17: 3 - Par", "Hole 18: 3 - Par"])
    end

    it "delivers the final output for a player" do
      score_card.final_output
      expect(score_card.final_string).to include("Total Score: 66")
    end

    it "writes all scores to CSV" do
      score_card.final_output
      score_card.write_to_csv
      f = File.read(File.open('final.txt'))
      expect(f).to include("Total Score: 66")
    end
  end

end


