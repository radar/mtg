# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoggMob do
  include_context "two player game"

  let!(:mob) { ResolvePermanent("Mogg Mob", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def activate(*targets, distribution: nil)
    p1.activate_ability(ability: mob.activated_abilities.first) { _1.targeting(*targets, distribution:) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/3" do
    expect([mob.power, mob.toughness]).to eq([3, 3])
  end

  it "sacrifices itself as a cost" do
    activate(p2)
    expect(p1.graveyard.cards.map(&:name)).to eq(["Mogg Mob"])
  end

  it "divides 3 damage among targets chosen on activation" do
    expect { activate(bears, p2, distribution: { bears => 2, p2 => 1 }) }.to change { p2.life }.by(-1)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "puts all 3 damage on a single target by default" do
    expect { activate(p2) }.to change { p2.life }.by(-3)
  end

  it "can target your own side too" do
    expect { activate(p1) }.to change { p1.life }.by(-3)
  end

  it "rejects a division that is not 3 damage" do
    expect { activate(p2, bears, distribution: { p2 => 1, bears => 1 }) }.to raise_error(/must divide 3/)
  end

  it "rejects zero damage to a target" do
    expect { activate(p2, bears, distribution: { p2 => 3, bears => 0 }) }.to raise_error(/must divide 3/)
  end

  it "rejects more than three targets" do
    extra = [ResolvePermanent("Grizzly Bears", owner: p2), ResolvePermanent("Grizzly Bears", owner: p2)]
    expect do
      activate(p1, p2, bears, extra[0], distribution: { p1 => 1, p2 => 1, bears => 1, extra[0] => 1 })
    end.to raise_error(/must divide 3/)
  end

  it "still sacrifices the Mob and keeps the targets chosen before it resolves" do
    activate(bears, p2, distribution: { bears => 1, p2 => 2 })
    expect(mob.zone).to be_nil
    expect(p2.life).to eq(18)
    expect(bears.damage).to eq(1)
  end

  it "skips a target that left the battlefield before the ability resolves" do
    p1.activate_ability(ability: mob.activated_abilities.first) { _1.targeting(bears, p2, distribution: { bears => 2, p2 => 1 }) }
    bears.destroy!
    game.stack.resolve!
    game.settle!
    expect(p2.life).to eq(19)
  end

  context "with a hexproof creature" do
    let!(:megalodon) { ResolvePermanent("Spined Megalodon", owner: p2) }

    it "can't target a hexproof creature of an opponent" do
      expect(mob.activated_abilities.first.valid_targets?(megalodon)).to eq(false)
      expect(mob.activated_abilities.first.valid_targets?(bears, p1, p2)).to eq(true)
      expect { activate(megalodon) }.to raise_error(/Invalid target/)
    end

    it "can still target a hexproof creature of your own" do
      mine = ResolvePermanent("Spined Megalodon", owner: p1)
      expect(mob.activated_abilities.first.valid_targets?(mine)).to eq(true)
    end
  end
end
