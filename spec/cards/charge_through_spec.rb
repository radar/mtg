require 'spec_helper'

RSpec.describe Magic::Cards::ChargeThrough do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  let(:eliminate) { Card("Eliminate", owner: p2) }
  let(:charge_through) { Card("Charge Through", owner: p1) }

  context "cast effect" do
    it "makes the player draw a card" do
      expect(p1).to receive(:draw!)
      p1.add_mana(green: 1)
      action = cast_action(player: p1, card: charge_through)
      action.pay_mana(green: 1)
      action.targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      game.tick!
      expect(wood_elves.trample?).to eq(true)
      expect(charge_through.zone).to be_graveyard
    end

    it "is invalid if target is destroyed" do
      expect(p1).not_to receive(:draw!)
      p1.add_mana(green: 1)
      action = cast_action(player: p1, card: charge_through)
      action.pay_mana(green: 1)
      action.targeting(wood_elves)
      game.take_action(action)

      p2.add_mana(black: 2)
      action_2 = cast_action(player: p2, card: eliminate)
      action_2.pay_mana(generic: { black: 1 }, black: 1)
      action_2.targeting(wood_elves)
      game.take_action(action_2)

      game.stack.resolve!

      expect(wood_elves).to be_dead
    end
  end
end
