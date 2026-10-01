# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AdornedCrocodile do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Adorned Crocodile", owner: p1) }

  it "creates a 2/2 black Zombie Druid token when it dies" do
    crocodile = ResolvePermanent("Adorned Crocodile", owner: p1)
    crocodile.destroy!
    game.settle!

    token = p1.creatures.find { |c| c.types.include?("Zombie") }
    expect(token.types).to include("Druid")
    expect([token.power, token.toughness]).to eq([2, 2])
  end

  it "renews for {B}: a +1/+1 counter on target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(black: 1)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(black: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect([bear.power, bear.toughness]).to eq([3, 3])
  end
end
