# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurnishedHart do
  include_context "two player game"

  let!(:hart) { ResolvePermanent("Burnished Hart", owner: p1) }

  it "is a 2/2 Elk artifact creature" do
    expect([hart.power, hart.toughness]).to eq([2, 2])
    expect(hart).to be_artifact
  end

  it "sacrifices itself to put up to two basic lands onto the battlefield tapped" do
    p1.add_mana(green: 3)
    p1.activate_ability(ability: hart.activated_abilities.first) { _1.pay_mana(generic: { green: 3 }) }
    game.stack.resolve!
    lands = p1.library.cards.select { _1.name == "Forest" }.first(2)
    game.resolve_choice!(targets: lands)
    game.tick!

    expect(hart.card.zone).to be_graveyard
    expect(p1.lands.count).to eq(2)
    expect(p1.lands).to all(be_tapped)
  end
end
