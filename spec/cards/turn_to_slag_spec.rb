# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TurnToSlag do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(target)
    card = Card("Turn To Slag", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 5)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 3 }, red: 2).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "deals 5 damage to the target creature" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p2) # 5/5
    cast(angel)

    expect(angel.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "destroys Equipment attached to the creature, even if the creature dies" do
    gear = ResolvePermanent("Adventuring Gear", owner: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    gear.attach_to!(bears)
    cast(bears)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(gear.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "destroys Equipment on a creature that survives" do
    gear = ResolvePermanent("Adventuring Gear", owner: p2)
    angel = ResolvePermanent("Serra Angel", owner: p2)
    angel.modify_base_toughness(9)
    game.tick!
    gear.attach_to!(angel)
    cast(angel)

    expect(angel.zone).to be_a(Magic::Zones::Battlefield)
    expect(gear.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "leaves Equipment on other creatures alone" do
    gear = ResolvePermanent("Adventuring Gear", owner: p2)
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    gear.attach_to!(other)
    cast(ResolvePermanent("Grizzly Bears", owner: p2))

    expect(gear.zone).to be_a(Magic::Zones::Battlefield)
  end
end
