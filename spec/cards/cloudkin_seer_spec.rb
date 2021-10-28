require 'spec_helper'

RSpec.describe Magic::Cards::CloudkinSeer do
  include_context "two player game"

  let(:forest) { Card("Forest") }

  before do
    p1.library.add(forest)
  end

  subject { described_class.new(game: game, controller: p1) }

  context "ETB effect" do
    it "controller draws a card" do
      subject.cast!
      expect(p1).to receive(:draw!)
      game.stack.resolve!
    end
  end

  context "flying?" do
    it "is flying" do
      expect(subject).to be_flying
    end
  end
end
