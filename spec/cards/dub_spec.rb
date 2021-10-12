require 'spec_helper'

RSpec.describe Magic::Cards::Dub do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  subject { Card("Dub", controller: p1) }

  context "resolution" do
    let(:wood_elves) { Card("Wood Elves", controller: p1) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "buffs wood elves, gives them first strike and makes them a knight" do
      subject.resolve!
      game.stack.resolve!
      expect(wood_elves.power).to eq(3)
      expect(wood_elves.toughness).to eq(3)
      expect(wood_elves.first_strike?).to eq(true)
      expect(wood_elves.type?("Knight")).to eq(true)
    end
  end
end
