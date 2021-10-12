require 'spec_helper'

RSpec.describe Magic::Cards::DefiantStrike do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player(library: [Card("Forest")]) }
  subject { Card("Defiant Strike", controller: p1) }

  context "resolution" do
    let(:wood_elves) { Card("Wood Elves", controller: p1) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "buffs a target + controller draws a card" do
      expect(p1).to receive(:draw!)
      subject.resolve!
      game.stack.resolve!
      expect(wood_elves.power).to eq(2)
    end
  end
end
