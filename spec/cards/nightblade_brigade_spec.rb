# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NightbladeBrigade do
  include_context "two player game"

  def warriors = p1.creatures.select { _1.name == "Warrior" }

  it "is a 1/3 deathtouch creature" do
    brigade = ResolvePermanent("Nightblade Brigade", owner: p1)
    expect([brigade.power, brigade.toughness]).to eq([1, 3])
    expect(brigade).to have_keyword(Magic::Cards::Keywords::DEATHTOUCH)
  end

  it "surveils 1 when it enters" do
    go_to_main_phase!
    p1.add_mana(black: 3)
    card = Card("Nightblade Brigade")
    p1.hand.add(card)
    p1.cast(card:) { |action| action.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!

    expect(game.choices.first).to be_a(Magic::Choice::Surveil)
  end

  it "mobilizes 1 when it attacks" do
    brigade = ResolvePermanent("Nightblade Brigade", owner: p1)
    game.skip_choice!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: brigade, target: p2)
    current_turn.attackers_declared!

    expect(warriors.size).to eq(1)
  end
end
