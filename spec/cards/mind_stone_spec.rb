require "spec_helper"

RSpec.describe Magic::Cards::MindStone do
  include_context "two player game"

  it "taps for colorless mana" do
    stone = ResolvePermanent("Mind Stone", owner: p1)
    p1.activate_ability(ability: stone.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "can be sacrificed to draw a card" do
    stone = ResolvePermanent("Mind Stone", owner: p1)
    hand_size = p1.hand.count
    p1.add_mana(colorless: 1)
    p1.activate_ability(ability: stone.activated_abilities.last) do |ability|
      ability.pay_mana(generic: { colorless: 1 })
    end
    game.stack.resolve!

    expect(stone.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand_size + 1)
  end
end