require 'spec_helper'

RSpec.describe Magic::Cards::DefiantStrike do
  include_context "two player game"

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
      buff = wood_elves.modifiers.first
      expect(buff.power).to eq(1)
      expect(buff.toughness).to eq(0)
      expect(buff.until_eot?).to eq(true)
      expect(wood_elves.power).to eq(2)

    end
  end
end
