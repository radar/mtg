# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SunTitan do
  include_context "two player game"

  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:angel) { Card("Baneslayer Angel", owner: p1) }
  let(:ring) { Card("Sol Ring", owner: p1) }
  let(:forest) { Card("Forest", owner: p1) }

  before { [bears, ring, forest, angel].each { p1.graveyard.add(_1) } }

  it "is a 6/6 with vigilance" do
    titan = ResolvePermanent("Sun Titan", owner: p1)
    expect([titan.power, titan.toughness]).to eq([6, 6])
    expect(titan).to have_keyword(:vigilance)
  end

  it "offers permanent cards with mana value 3 or less when it enters, not bigger ones" do
    ResolvePermanent("Sun Titan", owner: p1)

    expect(game.choices.last.choices).to contain_exactly(bears, ring, forest)
  end

  it "returns the chosen card to the battlefield" do
    ResolvePermanent("Sun Titan", owner: p1)
    game.resolve_choice!(target: bears)

    expect(p1.permanents.by_name("Grizzly Bears").count).to eq(1)
    expect(p1.graveyard.cards).not_to include(bears)
  end

  it "may decline" do
    ResolvePermanent("Sun Titan", owner: p1)
    game.skip_choice!

    expect(p1.permanents.by_name("Grizzly Bears")).to be_empty
  end

  it "does nothing when nothing in the graveyard qualifies" do
    p1.graveyard.cards.clear
    p1.graveyard.add(angel)
    ResolvePermanent("Sun Titan", owner: p1)

    expect(game.choices).to be_empty
  end

  it "triggers again when it attacks" do
    titan = ResolvePermanent("Sun Titan", owner: p1)
    game.resolve_choice!(target: ring)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: titan, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices.last.choices).to contain_exactly(bears, forest)
  end

  it "ignores the opponent's graveyard" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    p1.graveyard.cards.clear
    ResolvePermanent("Sun Titan", owner: p1)

    expect(game.choices).to be_empty
  end
end
