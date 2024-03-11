require "spec_helper"

RSpec.describe Magic::Cards::Unsubstantiate do
  include_context "two player game"


  context "spell on stack" do
    let(:shock) { Card("Shock", owner: p2) }
    let(:unsubstantiate) { Card("Unsubstantiate", owner: p1) }

    before do
      p2.hand.add(shock)
      p1.hand.add(unsubstantiate)
    end

    it "returns the spell to the owner's hand" do
      p2.add_mana(red: 1)
      p2.cast(card: shock) do
        _1.auto_pay_mana
      end

      p1.add_mana(blue: 2)
      p1.cast(card: unsubstantiate) do
        _1.auto_pay_mana
        _1.targeting(game.stack.first)
      end

      game.tick!

      expect(unsubstantiate.zone).to be_graveyard
      expect(shock.zone).to be_hand
      expect(p2.hand).to include(shock)
    end
  end

  context "creature on the field" do
    let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
    let(:unsubstantiate) { Card("Unsubstantiate", owner: p1) }

    before do
      p1.hand.add(unsubstantiate)
    end

    it "returns the creatureto the owner's hand" do
      p1.add_mana(blue: 2)
      p1.cast(card: unsubstantiate) do
        _1.auto_pay_mana
        _1.targeting(wood_elves)
      end

      game.tick!

      expect(unsubstantiate.zone).to be_graveyard
      expect(wood_elves.card.zone).to be_hand
      expect(p2.hand).to include(wood_elves.card)
    end
  end
end
