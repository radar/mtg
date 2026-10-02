# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OsseousExhale do
  include_context "two player game"

  let(:card) { Card("Osseous Exhale", owner: p1) }
  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:bystander) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    p1.add_mana(white: 2)
  end

  it "deals 5 damage to an attacking creature" do
    p1.cast(card: card) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(attacker) }
    game.stack.resolve!
    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.life).to eq(20)
  end

  it "can't target a creature that isn't attacking or blocking" do
    expect { p1.cast(card: card) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bystander) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "gains you 2 life if you behold a Dragon" do
    dragon = ResolvePermanent("Adult Gold Dragon", owner: p1)
    p1.cast(card: card) { |a| a.pay_mana(generic: { white: 1 }, white: 1).pay_kicker(dragon).targeting(attacker) }
    game.stack.resolve!
    expect(p1.life).to eq(22)
  end
end
