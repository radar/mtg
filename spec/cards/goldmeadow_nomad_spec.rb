# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoldmeadowNomad do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Goldmeadow Nomad", owner: p1) }

  it "is a 1/2 Kithkin Scout" do
    permanent = ResolvePermanent("Goldmeadow Nomad", owner: p1)

    expect(permanent.power).to eq(1)
    expect(permanent.toughness).to eq(2)
    expect(permanent.types).to include("Kithkin", "Scout")
  end

  it "exiles itself from the graveyard for {W} to create a 1/1 Kithkin token, as a sorcery" do
    p1.graveyard.add(card)
    p1.add_mana(white: 1)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(white: 1).pay_self_exile }
    game.stack.resolve!

    expect(card.zone).to be_exile
    token = p1.creatures.find { |c| c.types.include?("Kithkin") }
    expect(token.power).to eq(1)
    expect(token.toughness).to eq(1)
  end

  it "cannot be activated from the graveyard outside a main phase" do
    p1.graveyard.add(card)
    p1.add_mana(white: 1)
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(white: 1).pay_self_exile } }
      .to raise_error(Magic::IllegalAction)
  end
end
