# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AppendageAmalgam do
  include_context "two player game"

  let!(:amalgam) { ResolvePermanent("Appendage Amalgam", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 3/2 enchantment creature with flash" do
    expect([amalgam.power, amalgam.toughness]).to eq([3, 2])
    expect(amalgam).to be_flash
    expect(amalgam.type?("Enchantment")).to eq(true)
  end

  it "surveils 1 when it attacks" do
    attack_with(amalgam)

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "doesn't surveil when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(game.choices).to be_empty
  end
end
