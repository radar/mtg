# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ResurrectedCultist do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:cultist) { Card("Resurrected Cultist", owner: p1).tap { p1.graveyard.add(_1) } }

  def fill_graveyard!(*names)
    names.each { p1.graveyard.add(Card(_1, owner: p1)) }
  end

  # The Cultist is a creature, so these three cards add land, instant and artifact.
  def delirium! = fill_graveyard!("Forest", "Lightning Bolt", "Sol Ring")

  def return!
    p1.add_mana(black: 4)
    p1.activate_ability(ability: cultist.graveyard_abilities.first) { _1.pay_mana(generic: { black: 2 }, black: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/1 Human Cleric" do
    permanent = ResolvePermanent("Resurrected Cultist", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([4, 1])
  end

  it "returns to the battlefield with a finality counter with delirium" do
    cultist
    delirium!
    return!

    permanent = p1.permanents.find { _1.card == cultist }
    expect(permanent).not_to be_nil
    expect(permanent.counters.of_type(Magic::Counters::Finality).count).to eq(1)
  end

  it "is exiled instead of dying" do
    cultist
    delirium!
    return!
    p1.permanents.find { _1.card == cultist }.destroy!
    game.settle!

    expect(cultist.zone).to be_exile
  end

  it "can't be activated without four card types in your graveyard" do
    cultist
    fill_graveyard!("Forest", "Lightning Bolt")

    expect(cultist.graveyard_abilities.first).not_to be_requirements_met
  end

  it "can't be activated at instant speed" do
    cultist
    delirium!
    game.next_turn
    go_to_main_phase!

    expect(cultist.graveyard_abilities.first).not_to be_requirements_met
  end
end
