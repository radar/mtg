# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GandalfWanderingWizard do
  include_context "two player game"

  def p1_library = 20.times.map { Card("Island") }

  let!(:gandalf) { ResolvePermanent("Gandalf, Wandering Wizard", owner: p1) }

  it "is a 4/5 legendary Avatar Wizard" do
    expect([gandalf.power, gandalf.toughness]).to eq([4, 5])
    expect(gandalf.type?("Wizard")).to eq(true)
  end

  it "has ward {3}" do
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 1)
    p2.cast(card: Card("Burst Lightning", owner: p2)) { |a| a.pay_mana(red: 1).targeting(gandalf) }
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Ward)
  end

  it "shuffles into its owner's library and draws three cards for {6}" do
    p1.add_mana(blue: 6)
    expect do
      p1.activate_ability(ability: gandalf.activated_abilities.first) { _1.pay_mana(generic: { blue: 6 }) }
      game.stack.resolve!
    end.to change { p1.hand.count }.by(3)

    # It was shuffled into the library (so one of the three draws could even be Gandalf himself).
    expect(gandalf.card.zone).to be_library.or be_hand
    expect(game.battlefield.by_name("Gandalf, Wandering Wizard")).to be_empty
  end
end
