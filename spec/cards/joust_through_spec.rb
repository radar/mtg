# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JoustThrough do
  include_context "two player game"

  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:idle) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
  end

  it "deals 3 damage to target attacking creature and gains you 1 life" do
    p2.add_mana(white: 1)
    p2.cast(card: Card("Joust Through", owner: p2)) { |a| a.pay_mana(white: 1).targeting(attacker) }
    game.stack.resolve!
    game.tick!

    expect(attacker.card.zone).to be_graveyard
    expect(p2.life).to eq(21)
  end

  it "can't target a creature that isn't attacking or blocking" do
    p2.add_mana(white: 1)

    expect { p2.cast(card: Card("Joust Through", owner: p2)) { |a| a.pay_mana(white: 1).targeting(idle) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
