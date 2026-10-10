# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfTheDark do
  include_context "two player game"

  let!(:fear) { ResolvePermanent("Fear Of The Dark", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(fear, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 5/5 enchantment creature" do
    expect([fear.power, fear.toughness]).to eq([5, 5])
    expect(fear.type?("Enchantment")).to be(true)
  end

  it "gains menace and deathtouch when attacking a player with no Glimmer creatures" do
    attack!

    expect(fear).to be_menace
    expect(fear).to be_deathtouch
  end

  it "gains nothing when the defending player controls a Glimmer creature" do
    ResolvePermanent("Lionheart Glimmer", owner: p2)
    attack!

    expect(fear).not_to be_menace
    expect(fear).not_to be_deathtouch
  end
end
