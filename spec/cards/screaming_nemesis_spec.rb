# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScreamingNemesis do
  include_context "two player game"

  let!(:nemesis) { ResolvePermanent("Screaming Nemesis", owner: p1) }
  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def damage_nemesis!(amount)
    game.add_effect(Magic::Effects::DealDamage.new(source: attacker, target: nemesis, damage: amount))
    game.settle!
  end

  it "is a 3/3 with haste" do
    expect([nemesis.power, nemesis.toughness]).to eq([3, 3])
    expect(nemesis).to have_keyword(Magic::Cards::Keywords::HASTE)
  end

  it "deals that much damage to another target when dealt damage" do
    damage_nemesis!(2)

    expect(game.choices.first.choices).not_to include(nemesis)
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(p2.starting_life - 2)
  end

  it "stops a player dealt damage this way from gaining life" do
    damage_nemesis!(1)
    game.resolve_choice!(target: p2)
    game.settle!

    expect { p2.gain_life(3) }.not_to(change { p2.life })
    expect { p1.gain_life(3) }.to change { p1.life }.by(3)
  end

  it "doesn't stop life gain when it damages a creature" do
    damage_nemesis!(1)
    game.resolve_choice!(target: attacker)
    game.settle!

    expect { p2.gain_life(3) }.to change { p2.life }.by(3)
  end
end
