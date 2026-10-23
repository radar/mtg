# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrimsChant do
  include_context "two player game"

  let!(:chant) { Card("Orim's Chant", owner: p1).tap { p1.hand.add(_1) } }

  def cast_chant(target:, kicked: false)
    p1.add_mana(white: kicked ? 2 : 1)
    p1.cast(card: chant) do |a|
      a.pay_mana(white: 1)
      a.pay_kicker(white: 1) if kicked
      a.targeting(target)
    end
    game.stack.resolve!
  end

  it "stops the target player casting spells this turn" do
    cast_chant(target: p2)

    expect(p2.spell_cast_limit_reached?).to be(true)
    expect(p1.spell_cast_limit_reached?).to be_falsey
  end

  it "lets creatures attack when not kicked" do
    go_to_main_phase!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_chant(target: p2)
    skip_to_combat!
    current_turn.declare_attackers!

    expect { p1.declare_attacker(attacker: bears, target: p2) }.not_to raise_error
    expect(current_turn.attacking?(bears)).to be(true)
  end

  it "stops creatures attacking this turn when kicked" do
    go_to_main_phase!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_chant(target: p2, kicked: true)
    skip_to_combat!
    current_turn.declare_attackers!

    expect { p1.declare_attacker(attacker: bears, target: p2) }.to raise_error(Magic::IllegalAction, /can't attack/)
  end
end
