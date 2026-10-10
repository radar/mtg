# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfSurveillance do
  include_context "two player game"

  let!(:fear) { ResolvePermanent("Fear Of Surveillance", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2 vigilance enchantment creature" do
    expect([fear.power, fear.toughness]).to eq([2, 2])
    expect(fear.has_keyword?(:vigilance)).to eq(true)
    expect(fear.type?("Enchantment")).to eq(true)
  end

  it "surveils 1 when it attacks" do
    attack_with(fear)

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "doesn't surveil when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(game.choices).to be_empty
  end
end
