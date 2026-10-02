# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoltenExhale do
  include_context "two player game"

  let(:card) { Card("Molten Exhale", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "deals 4 damage to target creature at sorcery speed" do
    go_to_main_phase!
    p1.add_mana(red: 2)
    p1.cast(card: card) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) }
    game.stack.resolve!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "can't be cast on an opponent's turn without a Dragon" do
    go_to_main_phase_for!(p2)
    p1.add_mana(red: 2)
    expect { p1.cast(card: card) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) } }.to raise_error(Magic::IllegalAction)
  end

  it "can be cast as though it had flash if you behold a Dragon (on the battlefield)" do
    dragon = ResolvePermanent("Adult Gold Dragon", owner: p1)
    go_to_main_phase_for!(p2)
    p1.add_mana(red: 2)
    p1.cast(card: card) { |a| a.pay_mana(generic: { red: 1 }, red: 1).pay_kicker(dragon).targeting(bears) }
    game.stack.resolve!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "can be cast as though it had flash if you behold a Dragon (revealed from hand)" do
    dragon = Card("Adult Gold Dragon", owner: p1)
    p1.hand.add(dragon)
    go_to_main_phase_for!(p2)
    p1.add_mana(red: 2)
    p1.cast(card: card) { |a| a.pay_mana(generic: { red: 1 }, red: 1).pay_kicker(dragon).targeting(bears) }
    game.stack.resolve!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.hand.cards).to include(dragon)
  end
end
