require 'spec_helper'

RSpec.describe Magic::Cards::EnthrallingHold do
  include_context "two player game"

  subject { Card("Enthralling Hold") }

  context "resolution" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "equips aura, changes permanent controller" do
      wood_elves.tap!
      p1.add_mana(blue: 5)
      action = cast_action(player: p1, card: subject)
        .pay_mana(blue: 2, generic: { blue: 3 })
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!

      expect(wood_elves.controller).to eq(p1)
    end

    it "cannot target an untapped wood elves" do
      action = cast_action(player: p1, card: subject)

      expect(action.can_target?(wood_elves)).to eq(false)
    end
  end
end
