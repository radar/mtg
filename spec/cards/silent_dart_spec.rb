require "spec_helper"

RSpec.describe Magic::Cards::SilentDart do
  include_context "two player game"

  subject(:permanent) { ResolvePermanent("Silent Dart") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves") }

  it "deals 3 damage to any target" do
    expect(game.battlefield.creatures.count).to eq(1)

    p1.add_mana(black: 4)
    p1.activate_ability(ability: permanent.activated_abilities.first) do
      _1.targeting(wood_elves)
      _1.pay_mana(generic: { black: 4 })
    end

    expect(wood_elves.damage).to eq(3)
  end
end
