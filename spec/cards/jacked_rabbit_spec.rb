# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JackedRabbit do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(x:)
    card = Card("Jacked Rabbit", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: x + 2)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { white: x }, generic: { white: 1 }, white: 1) }
    game.stack.resolve!
    game.settle!
    p1.permanents.by_name("Jacked Rabbit").first
  end

  def rabbits = p1.creatures.select { _1.name == "Rabbit" && _1.token? }

  it "is a 1/2 with no counters at X = 0" do
    rabbit = cast(x: 0)
    expect([rabbit.power, rabbit.toughness]).to eq([1, 2])
  end

  it "enters with X +1/+1 counters" do
    rabbit = cast(x: 3)
    game.tick!

    expect([rabbit.power, rabbit.toughness]).to eq([4, 5])
  end

  it "draws a card when X is 5 or more" do
    # `cast` adds the card to the hand and casts it (net 0), so a net +1 is the draw.
    expect { cast(x: 5) }.to change { p1.hand.count }.by(1)
  end

  it "does not draw when X is 4" do
    expect { cast(x: 4) }.not_to change { p1.hand.count }
  end

  it "creates Rabbits equal to its power when it attacks" do
    rabbit = cast(x: 2)
    rabbit.controlled_since_turn = 0 # no longer summoning sick
    game.tick!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: rabbit, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(rabbits.count).to eq(3)
    expect([rabbits.first.power, rabbits.first.toughness]).to eq([1, 1])
  end
end
