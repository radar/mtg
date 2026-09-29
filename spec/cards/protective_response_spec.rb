# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ProtectiveResponse do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Protective Response", owner: p1) }

  it "has convoke" do
    expect(card.convoke?).to be(true)
  end

  it "destroys target attacking creature" do
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p1)
    p1.hand.add(card)
    p1.add_mana(white: 3)
    p1.cast(card:) { _1.pay_mana(generic: { white: 2 }, white: 1).targeting(attacker) }
    game.stack.resolve!

    expect(attacker.card.zone).to be_graveyard
  end

  it "destroys target blocking creature" do
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    blocker = ResolvePermanent("Courser Of Kruphix", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker:)
    p1.hand.add(card)
    p1.add_mana(white: 3)
    p1.cast(card:) { _1.pay_mana(generic: { white: 2 }, white: 1).targeting(blocker) }
    game.stack.resolve!

    expect(blocker.card.zone).to be_graveyard
  end

  it "can't target a creature that isn't attacking or blocking" do
    idle = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(card.target_choices).not_to include(idle)
  end

  it "can be cast by tapping creatures" do
    helpers = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
    attacker = ResolvePermanent("Courser Of Kruphix", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p1)
    p1.hand.add(card)
    p1.add_mana(white: 1)
    p1.cast(card:) do |action|
      helpers.each { action.convoke(_1) }
      action.pay_mana(white: 1).targeting(attacker)
    end
    game.stack.resolve!

    expect(helpers).to all(be_tapped)
    expect(attacker.card.zone).to be_graveyard
  end
end
