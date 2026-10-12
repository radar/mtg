# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BejeweledWarg do
  include_context "two player game"

  let!(:warg) { ResolvePermanent("Bejeweled Warg", owner: p1) }

  def combat_damage(source = warg, to: p2)
    game.notify!(Magic::Events::DamageDealt.new(source: source, target: to, damage: 3, combat: true))
    game.settle!
  end

  it "is a 3/2 Wolf with trample" do
    expect([warg.power, warg.toughness]).to eq([3, 2])
    expect(warg.card.types).to include("Wolf")
    expect(warg.trample?).to be(true)
  end

  it "can put a +1/+1 counter on a Wolf you control" do
    other = ResolvePermanent("Ambush Wolf", owner: p1)
    before_power = other.power
    combat_damage
    game.resolve_choice!(mode: :counter, target: other)
    game.tick!

    expect(other.power).to eq(before_power + 1)
  end

  it "can put the counter on itself" do
    combat_damage
    game.resolve_choice!(mode: :counter, target: warg)
    game.tick!

    expect([warg.power, warg.toughness]).to eq([4, 3])
  end

  it "can create a Treasure token" do
    combat_damage
    game.resolve_choice!(mode: :treasure)

    expect(p1.permanents.count { _1.name == "Treasure" }).to eq(1)
  end

  it "doesn't trigger on damage to a creature or noncombat damage" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    combat_damage(warg, to: theirs)
    game.notify!(Magic::Events::DamageDealt.new(source: warg, target: p2, damage: 3, combat: false))
    game.settle!

    expect(game.choices).to be_empty
  end
end
