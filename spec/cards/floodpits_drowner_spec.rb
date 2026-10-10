# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FloodpitsDrowner do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 2/1 Merfolk with flash and vigilance" do
    drowner = ResolvePermanent("Floodpits Drowner", owner: p1)
    game.settle!

    expect([drowner.power, drowner.toughness]).to eq([2, 1])
    expect(drowner.has_keyword?(:flash)).to be(true)
    expect(drowner.has_keyword?(:vigilance)).to be(true)
  end

  it "taps target opposing creature and stuns it when it enters" do
    ResolvePermanent("Floodpits Drowner", owner: p1)
    game.settle!

    expect(bear).to be_tapped
    expect(bear.counters.of_type(Magic::Counters::Stun).count).to eq(1)
  end

  it "shuffles itself and a creature with a stun counter into their owners' libraries" do
    drowner = ResolvePermanent("Floodpits Drowner", owner: p1)
    game.settle!
    drowner.untap!
    bear_card = bear.card
    drowner_card = drowner.card
    p1.add_mana(blue: 2)

    p1.activate_ability(ability: drowner.activated_abilities.first) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(bear) }
    game.stack.resolve!
    game.settle!

    expect(p1.creatures).to be_empty
    expect(p2.creatures).to be_empty
    expect(p1.library.cards).to include(drowner_card)
    expect(p2.library.cards).to include(bear_card)
  end
end
