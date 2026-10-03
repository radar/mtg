# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DrakusethMawOfFlames do
  include_context "two player game"

  let!(:drakuseth) { ResolvePermanent("Drakuseth, Maw Of Flames", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:wizard) { ResolvePermanent("Erudite Wizard", owner: p2) }

  # Declares Drakuseth as an attacker; the trigger is queued and its first choice (the 4-damage target) is pending.
  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(drakuseth, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary 7/7 flying Dragon" do
    expect([drakuseth.power, drakuseth.toughness]).to eq([7, 7])
    expect(drakuseth).to be_flying
    expect(drakuseth).to be_legendary
  end

  it "deals 4 damage to any target, then 3 damage to each of up to two other targets" do
    attack
    game.resolve_choice!(target: wizard) # 4 damage: dies (2/3)
    game.resolve_choice!(target: bears)  # 3 damage: dies (2/2)
    game.resolve_choice!(target: p2)     # 3 damage to the player
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Erudite Wizard", "Grizzly Bears")
    expect(p2.life).to eq(17)
    expect(game.choices).to be_empty
  end

  it "may choose fewer than two other targets" do
    attack
    game.resolve_choice!(target: p2)
    game.resolve_choice!(target: bears)
    game.skip_choice!
    game.settle!

    expect(p2.life).to eq(16)
    expect(bears.card.zone).to be_graveyard
    expect(wizard.zone).to be_battlefield
    expect(game.choices).to be_empty
  end

  it "may choose no other targets" do
    attack
    game.resolve_choice!(target: p2)
    game.skip_choice!
    game.settle!

    expect(p2.life).to eq(16)
    expect(game.choices).to be_empty
  end

  it "doesn't offer an earlier target again" do
    attack
    game.resolve_choice!(target: p2)

    expect(game.choices.last.choices).not_to include(p2)
    game.resolve_choice!(target: bears)
    expect(game.choices.last.choices).not_to include(p2, bears)
  end

  it "doesn't trigger when another creature attacks" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(other, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices).to be_empty
  end
end
