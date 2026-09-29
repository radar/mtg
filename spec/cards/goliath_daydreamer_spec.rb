# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoliathDaydreamer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:goliath) { ResolvePermanent("Goliath Daydreamer", owner: p1) }

  it "is a 4/4 Giant Wizard" do
    expect(goliath.power).to eq(4)
    expect(goliath.toughness).to eq(4)
  end

  def cast_bolt_from_hand(target)
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
    bolt
  end

  it "exiles an instant or sorcery cast from your hand with a dream counter instead of putting it in the graveyard" do
    bolt = cast_bolt_from_hand(p2)

    expect(p2.life).to eq(17)
    expect(bolt.zone).to be_exile
    expect(bolt.dream_counter).to be(true)
    expect(p1.graveyard.cards).not_to include(bolt)
  end

  it "does not do this for spells cast by an opponent" do
    go_to_main_phase_for!(p2)
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p1) }
    game.stack.resolve!
    game.settle!

    expect(bolt.zone).to be_graveyard
  end

  it "does not do this for creature spells" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    p1.add_mana(green: 2)
    p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.settle!

    expect(bears.dream_counter).to be_falsy
  end

  it "does not exile a spell that was countered" do
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    bolt.exile_with_dream_counter = true # as if the trigger had already resolved
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.stack.counter!(game.stack.spells.first)

    expect(bolt.zone).to be_graveyard
    expect(bolt.exile_with_dream_counter).to be_falsy
  end

  it "lets you cast a dream-counter card for free when it attacks" do
    bolt = cast_bolt_from_hand(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: goliath, target: p2)
    current_turn.attackers_declared!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(described_class::CastChoice)
    game.resolve_choice!(target: bolt, targets: [p2])
    game.stack.resolve!

    expect(p2.life).to eq(14)
    expect(bolt.zone).to be_graveyard
  end

  it "offers no choice when there is nothing exiled with a dream counter" do
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: goliath, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices).to be_empty
  end
end
