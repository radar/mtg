require 'spec_helper'

RSpec.describe Magic::Cards::SecureTheScene do
  include_context "two player game"

  subject(:secure_the_scene) { Card("Secure The Scene") }

  context "with a creature" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "exiles the wood elves, replaces them with a 1/1 White Soldier" do
      p1.add_mana(white: 5)
      p1.cast(card: secure_the_scene) do
        _1.pay_mana(generic: { white: 4 }, white: 1)
          .targeting(wood_elves)
      end
      game.stack.resolve!

      expect(wood_elves.card.zone).to be_exile
      soldier = creatures.controlled_by(p2).first
      expect(soldier.name).to eq("Soldier")
      expect(soldier.power).to eq(1)
      expect(soldier.toughness).to eq(1)
      expect(soldier.colors).to eq([:white])
    end
  end

end
