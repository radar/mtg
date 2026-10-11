# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BalustradeWurm do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:wurm) { Card("Balustrade Wurm", owner: p1).tap { p1.graveyard.add(_1) } }

  def delirium! = %w[Forest Lightning\ Bolt Sol\ Ring].each { p1.graveyard.add(Card(_1, owner: p1)) }

  def return!
    p1.add_mana(green: 4)
    p1.activate_ability(ability: wurm.graveyard_abilities.first) { _1.pay_mana(generic: { green: 2 }, green: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 5/5 with trample and haste that can't be countered" do
    permanent = ResolvePermanent("Balustrade Wurm", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([5, 5])
    expect(permanent).to have_keyword(:trample)
    expect(permanent).to have_keyword(:haste)
    expect(permanent.card.can_be_countered?).to be(false)
  end

  it "returns from the graveyard with a finality counter when you have delirium" do
    wurm
    delirium!
    return!

    permanent = p1.permanents.find { _1.card == wurm }
    expect(permanent.counters.of_type(Magic::Counters::Finality).count).to eq(1)
  end

  it "is exiled instead of dying after returning" do
    wurm
    delirium!
    return!
    p1.permanents.find { _1.card == wurm }.destroy!
    game.settle!

    expect(wurm.zone).to be_exile
  end

  it "can't return without delirium" do
    wurm

    expect(wurm.graveyard_abilities.first).not_to be_requirements_met
  end
end
