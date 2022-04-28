require 'spec_helper'

RSpec.describe Magic::Cards::SecureTheScene do
  include_context "two player game"

  let(:card) { described_class.new(game: game, controller: p1) }

  context "with a creature" do
    let(:wood_elves) { Card("Wood Elves", game: game, controller: p2) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "exiles the wood elves, replaces them with a 1/1 White Soldier" do
      p1.add_mana(white: 5)
      cast_action = p1.prepare_to_cast(card).targeting(wood_elves)
      cast_action.pay(generic: { white: 4 }, white: 1)
      cast_action.perform!
      game.stack.resolve!
      expect(wood_elves.zone).to be_exile
      soldier = game.battlefield.creatures.controlled_by(p2).first
      expect(soldier.name).to eq("Soldier")
      expect(soldier.power).to eq(1)
      expect(soldier.toughness).to eq(1)
      expect(soldier.colors).to eq([:white])
    end
  end

end
