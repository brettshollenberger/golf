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

  it "loads a CSV of player scores" do
    empty_card.load_file(example_scores_file)
    expect(empty_card).to be_kind_of(Hash)
    expect(empty_card['Woods']).to be_kind_of(Array)
    expect(empty_card['Woods']).to eql([1, 4, 5, 3, 4, 5, 4, 4, 5, 3, 4, 5, 3, 3, 4, 5, 3, 3])
  end

  it "loads a Hole Layout" do
    score_card.load_course(example_course_file)
    expect(score_card.course).to eql([3, 4, 5, 3, 4, 5, 4, 4, 5, 3, 4, 5, 3, 3, 4, 5, 3, 3])
  end

  it "can tell par of an individual hole" do
    score_card.load_course(example_course_file)
    expect(score_card.course[0]). to eql(3)
  end

  it "loads all the scores of an individual player" do
    expect(score_card['Woods'][0]).to eql(1)
    expect(score_card['Woods'][1]).to eql(4)
  end

  it "tells a player's deviation from par for an individual hole" do
    score_card.load_course(example_course_file)
    score1, ace = score_card.deviation(1, 'Woods')
    score2, ace = score_card.deviation(2, 'Woods')
    expect(score1).to eql(-2)
    expect(score2).to eql(0)
  end

  it "scores par for a deviation of 0" do
    score_card.load_course(example_course_file)
    expect(score_card.score(0, false)).to eql("par")
  end

  it "scores bogey for a deviation of 1" do
    score_card.load_course(example_course_file)
    expect(score_card.score(1, false)).to eql("bogey")
  end

  it "scores birdie for a deviation of -1" do
    score_card.load_course(example_course_file)
    expect(score_card.score(-1, false)).to eql("birdie")
  end

  it "scores eagle for a deviation of -2" do
    score_card.load_course(example_course_file)
    expect(score_card.score(-2, false)).to eql("eagle")
  end

  it "scores ace for a hole in one" do
    score_card.load_course(example_course_file)
    deviation, ace = score_card.deviation(1, 'Woods')
    expect(score_card.score(deviation, ace)).to eql("ace")
  end

  it "calculates very large bogeys" do
    score_card.load_course(example_course_file)
    expect(score_card.score(15, false)).to eql("14x bogey")
  end

  it "calculates a player's total score" do
    score_card.load_course(example_course_file)
    expect(score_card.total_score('Woods')).to eql(-2)
  end

end


