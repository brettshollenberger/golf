require 'rspec'
require_relative '../lib/golf.rb'

describe HoleLayout do

  let(:correct_layout) { HoleLayout.new().push(3, 4, 5, 3, 4, 5, 4, 4, 5, 3, 4, 5, 3, 3, 4, 5, 3, 3) }
  let(:empty_layout) { HoleLayout.new() }
  let(:example_file) { 'example_file.csv' }

  it "calculates the par for the course" do
    expect(correct_layout.par).to eql(70)
  end

  it "loads a CSV" do
    empty_layout.load_file(example_file)
    expect(empty_layout.par).to eql(70)
  end


end
