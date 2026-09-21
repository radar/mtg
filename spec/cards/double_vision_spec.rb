# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DoubleVision do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:double_vision) { ResolvePermanent("Double Vision", owner: p1) }
  let(:bolt) { Card("Lightning Bolt", owner: p1) }

  before do
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
  end

  it "copies the first instant or sorcery spell cast each turn, resolving the copy against the original target" do
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.skip_choice!
    game.stack.resolve!

    expect(p2.life).to eq(14)
  end

  it "may choose new targets for the copy" do
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.resolve_choice!
    game.resolve_choice!(target: p1)
    game.stack.resolve!

    expect(p1.life).to eq(17)
    expect(p2.life).to eq(17)
  end

  it "does not copy the second instant or sorcery spell cast in the same turn" do
    other_bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(other_bolt)
    p1.add_mana(red: 1)

    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.skip_choice!
    game.stack.resolve!

    p1.cast(card: other_bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(11)
  end

  it "does not trigger on a creature spell" do
    bear = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bear)
    p1.add_mana(green: 2)

    p1.cast(card: bear) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    expect(p1.creatures.count).to eq(1)
  end
end
