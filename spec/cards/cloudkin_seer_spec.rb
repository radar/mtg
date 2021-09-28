require 'spec_helper'

RSpec.describe Magic::Cards::CloudkinSeer do
  let(:game) { Magic::Game.new }
  let(:forest) { Magic::Cards::Forest.new }
  let(:p1) { game.add_player(library: [forest]) }
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
