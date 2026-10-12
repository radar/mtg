# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TroopOfPonies do
  include_context "two player game"

  let!(:ponies) { ResolvePermanent("Troop Of Ponies", owner: p1) }

  before do
    p1.library.add(Card("Forest", owner: p1))
    p1.library.add(Card("Island", owner: p1))
  end

  it "is a 2/1 Horse" do
    expect([ponies.power, ponies.toughness]).to eq([2, 1])
  end

  it "sacrifices to fetch one basic onto the battlefield tapped and one to hand" do
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: ponies.activated_abilities.first) do
      _1.pay_mana(generic: { colorless: 2 })
    end
    game.stack.resolve!

    expect(ponies.card.zone).to be_graveyard
    choice = game.choices.last
    forest = choice.choices.find { _1.name == "Forest" }
    island = choice.choices.find { _1.name == "Island" }
    game.resolve_choice!(targets: [forest, island])

    land = p1.lands.find { _1.name == "Forest" }
    expect(land).to be_tapped
    expect(p1.hand.cards).to include(island)
  end
end
