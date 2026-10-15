# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoggMob do
  include_context "two player game"

  let!(:mob) { ResolvePermanent("Mogg Mob", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def activate
    p1.activate_ability(ability: mob.activated_abilities.first)
    game.stack.resolve!
  end

  it "is a 3/3" do
    expect([mob.power, mob.toughness]).to eq([3, 3])
  end

  it "sacrifices itself as a cost" do
    activate
    expect(p1.graveyard.cards.map(&:name)).to eq(["Mogg Mob"])
  end

  it "divides 3 damage among targets" do
    activate
    expect { game.resolve_choice!(distribution: { bears => 2, p2 => 1 }) }.to change { p2.life }.by(-1)
    game.settle!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "can put all 3 damage on one target" do
    activate
    expect { game.resolve_choice!(distribution: { p2 => 3 }) }.to change { p2.life }.by(-3)
  end

  it "can target your own side too" do
    activate
    expect { game.resolve_choice!(distribution: { p1 => 3 }) }.to change { p1.life }.by(-3)
  end

  it "rejects a division that is not 3 damage" do
    activate
    expect { game.resolve_choice!(distribution: { p2 => 2 }) }.to raise_error(ArgumentError)
  end

  it "rejects zero damage to a target" do
    activate
    expect { game.resolve_choice!(distribution: { p2 => 3, bears => 0 }) }.to raise_error(ArgumentError)
  end

  it "rejects more than three targets" do
    extra = [ResolvePermanent("Grizzly Bears", owner: p2), ResolvePermanent("Grizzly Bears", owner: p2)]
    activate
    expect { game.resolve_choice!(distribution: { p2 => 1, bears => 1, extra[0] => 1, extra[1] => 0 }) }.to raise_error(ArgumentError)
    expect { game.resolve_choice!(distribution: { p1 => 1, p2 => 1, bears => 1, extra[0] => 1 }) }.to raise_error(ArgumentError)
  end

  it "puts all damage on one target when the choice is skipped" do
    activate
    first = game.choices.last.choices.first
    game.skip_choice!
    game.settle!
    if first.is_a?(Magic::Player)
      expect(first.life).to eq(17)
    else
      expect(first.zone).to be_nil
    end
  end
end
