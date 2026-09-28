# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StoicGroveGuide do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Stoic Grove-Guide", owner: p1) }

  it "is a 5/4 Elf Druid" do
    permanent = ResolvePermanent("Stoic Grove-Guide", owner: p1)

    expect(permanent.power).to eq(5)
    expect(permanent.toughness).to eq(4)
    expect(permanent.types).to include("Elf", "Druid")
  end

  it "exiles itself from the graveyard for {1}{B/G} to create a 2/2 Elf token, as a sorcery" do
    p1.graveyard.add(card)
    p1.add_mana(green: 2)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_self_exile }
    game.stack.resolve!

    expect(card.zone).to be_exile
    token = p1.creatures.find { |c| c.types.include?("Elf") }
    expect(token.power).to eq(2)
    expect(token.toughness).to eq(2)
  end

  it "cannot be activated from the graveyard outside a main phase" do
    p1.graveyard.add(card)
    p1.add_mana(green: 2)
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_self_exile } }
      .to raise_error(Magic::IllegalAction)
  end
end
