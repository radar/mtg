# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LilianasSteward do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:steward) { ResolvePermanent("Liliana's Steward", owner: p1) }

  it "is a 1/2 Zombie" do
    expect([steward.power, steward.toughness]).to eq([1, 2])
  end

  it "sacrifices itself to make target opponent discard a card" do
    card = p2.hand.cards.first
    p1.activate_ability(ability: steward.activated_abilities.first) { _1.targeting(p2) }
    game.stack.resolve!
    game.settle!
    game.resolve_choice!(card:)

    expect(steward.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(card.zone).to be_graveyard
  end

  it "can't be activated on an opponent's turn" do
    go_to_main_phase_for!(p2)

    expect { p1.activate_ability(ability: steward.activated_abilities.first) { _1.targeting(p2) } }.to raise_error(StandardError)
  end
end
