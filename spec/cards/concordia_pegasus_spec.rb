require 'spec_helper'

RSpec.describe Magic::Cards::ConcordiaPegasus do
  include_context "two player game"

  let(:game) { Magic::Game.new }
  subject { Card("Concordia Pegasus") }

  it "has flying" do
    expect(subject).to be_flying
  end
end
