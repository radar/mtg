# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExpeditionMap do
  include_context "two player game"

  let!(:map) { ResolvePermanent("Expedition Map", owner: p1) }

  it "sacrifices itself to search your library for a land card and put it into your hand" do
    p1.add_mana(green: 2)
    p1.activate_ability(ability: map.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }) }
    game.stack.resolve!
    land = p1.library.cards.find { _1.name == "Forest" }
    game.resolve_choice!(targets: [land])

    expect(map.card.zone).to be_graveyard
    expect(land.zone).to be_hand
  end

  it "needs {2} to activate" do
    expect { p1.activate_ability(ability: map.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }) } }
      .to raise_error(StandardError)
  end
end
