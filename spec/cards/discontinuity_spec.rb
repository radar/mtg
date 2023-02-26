require 'spec_helper'

RSpec.describe Magic::Cards::Discontinuity do
  include_context "two player game"

  subject { Card("Discontinuity") }

  context "resolution" do
    let!(:wood_elves) { Card("Wood Elves") }

    context "cost reduction" do
      it "regular cost when non-active-player casts it" do
        p1.add_mana(green: 3)
        action = cast_action(player: p1, card: wood_elves)
          .pay_mana(green: 1, generic: { green: 2 })
        game.take_action(action)

        p2.add_mana(blue: 6)
        action = cast_action(player: p2, card: subject)
        expect(action.mana_cost.generic).to eq(3)
        expect(action.mana_cost.blue).to eq(3)
      end

      it "discounted cost when active player casts it" do
        p1.add_mana(green: 3)
        action = cast_action(player: p1, card: wood_elves)
          .pay_mana(green: 1, generic: { green: 2 })
        game.take_action(action)

        p1.add_mana(blue: 2)

        action = cast_action(player: p1, card: subject)
        expect(action.mana_cost.generic).to eq(1)
        expect(action.mana_cost.blue).to eq(1)
      end
    end


    it "exiles spells from the stack" do
      p1.add_mana(green: 3)
      action = cast_action(player: p1, card: wood_elves)
        .pay_mana(green: 1, generic: { green: 2 })
      game.take_action(action)

      p2.add_mana(blue: 6)
      action = cast_action(player: p2, card: subject)
      expect(action.mana_cost.generic).to eq(3)
      expect(action.mana_cost.blue).to eq(3)
      action.pay_mana(blue: 3, generic: { blue: 3 })
      game.take_action(action)

      game.stack.resolve!

      expect(game.stack).to be_empty
      expect(game.battlefield.creatures.by_name(wood_elves.name)).to be_empty
      expect(game.current_turn.step).to eq("end")
    end
  end
end
