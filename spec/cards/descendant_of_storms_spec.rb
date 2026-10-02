# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DescendantOfStorms do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Descendant Of Storms", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: permanent, target: p2)
    current_turn.attackers_declared!
  end

  def counters = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "pays {1}{W} when it attacks, then endures 1" do
    p1.add_mana(white: 2)
    attack!
    game.resolve_choice!
    game.resolve_choice!
    expect(counters).to eq(1)
  end

  it "makes a 1/1 Spirit instead if you decline the counter" do
    p1.add_mana(white: 2)
    attack!
    game.resolve_choice!
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([1, 1])
  end

  it "does nothing if you decline to pay" do
    p1.add_mana(white: 2)
    attack!
    game.skip_choice!
    expect(counters).to eq(0)
    expect(p1.permanents.none? { _1.name == "Spirit" }).to be(true)
  end

  it "does nothing without the mana" do
    attack!
    expect(game.choices).to be_empty
  end
end
