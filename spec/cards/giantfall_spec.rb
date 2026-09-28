# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Giantfall do
  include_context "two player game"

  let(:card) { Card("Giantfall", owner: p1) }

  before { p1.hand.add(card) }

  it "deals damage equal to a creature you control's power to a target creature an opponent controls" do
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    victim = ResolvePermanent("Boneclub Berserker", owner: p2) # 2/4, survives 2 damage
    p1.add_mana(red: 2)

    p1.cast(card:) do |a|
      a.pay_mana(generic: { red: 1 }, red: 1)
      a.choose_mode(described_class::FightDamage) { _1.targeting(attacker, victim) }
    end
    game.stack.resolve!

    expect(victim.damage).to eq(2)
  end

  it "destroys target artifact instead" do
    artifact = ResolvePermanent("Mind Stone", owner: p2)
    p1.add_mana(red: 2)

    p1.cast(card:) do |a|
      a.pay_mana(generic: { red: 1 }, red: 1)
      a.choose_mode(described_class::DestroyArtifact) { _1.targeting(artifact) }
    end
    game.stack.resolve!

    expect(artifact.card.zone).to be_graveyard
  end
end
