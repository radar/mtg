# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Progenitus do
  include_context "two player game"

  let!(:progenitus) { ResolvePermanent("Progenitus", owner: p1) }

  it "is a 10/10 legendary Hydra Avatar" do
    expect([progenitus.power, progenitus.toughness]).to eq([10, 10])
    expect(progenitus.type?("Hydra")).to eq(true)
  end

  it "can't be targeted by spells" do
    lightning = Card("Burst Lightning", owner: p2)
    p2.hand.add(lightning)

    expect { cast_action(card: lightning, player: p2, targeting: progenitus) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't be blocked, since protection from everything includes every creature" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(progenitus, target: p2)
    current_turn.attackers_declared!

    expect(current_turn.can_block?(attacker: progenitus, blocker: blocker)).to eq(false)
    expect { current_turn.declare_blocker(blocker, attacker: progenitus) }.to raise_error(Magic::Game::CombatPhase::AttackerHasProtection)
  end

  it "is shuffled into its owner's library instead of going to the graveyard" do
    library_size = p1.library.cards.count
    progenitus.sacrifice!
    game.settle!

    expect(progenitus.card.zone).to be_library
    expect(p1.library.cards.count).to eq(library_size + 1)
    expect(p1.graveyard.cards).not_to include(progenitus.card)
  end

  it "is shuffled into the library instead of being discarded" do
    card = Card("Progenitus", owner: p1)
    p1.hand.add(card)
    card.discard!

    expect(card.zone).to be_library
  end
end
