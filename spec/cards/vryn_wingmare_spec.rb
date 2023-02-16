require 'spec_helper'

RSpec.describe Magic::Cards::ValorousSteed do
  include_context "two player game"

  subject!(:vryn_wingmare) { ResolvePermanent("Vryn Wingmare", owner: p1) }
  let(:counterspell) { Card("Counterspell") }
  let(:wood_elves) { Card("Wood Elves") }


  it "causes non-creature spells to cost 1 more" do
    ability = game.battlefield.static_abilities.first
    expect(ability).to be_a(Magic::Abilities::Static::ManaCostAdjustment)
    expect(ability.adjustment).to eq(generic: 1)

    aggregate_failures do
      action = cast_action(card: counterspell, player: p1)
      expect(action.mana_cost.blue).to eq(2)
      expect(action.mana_cost.generic).to eq(1)

      action = cast_action(card: wood_elves, player: p1)
      expect(action.mana_cost.green).to eq(1)
      expect(action.mana_cost.generic).to eq(2)
    end
  end
end
