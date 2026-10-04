# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SoulShackledZombie do
  include_context "two player game"

  let(:their_creature) { Card("Grizzly Bears", owner: p2) }
  let(:their_spell) { Card("Boltwave", owner: p2) }
  let(:my_creature) { Card("Diregraf Ghoul", owner: p1) }

  def enter!
    ResolvePermanent("Soul Shackled Zombie", owner: p1, settle: false)
    game.settle!
  end

  it "is a 4/2 Zombie" do
    zombie = ResolvePermanent("Soul Shackled Zombie", owner: p1)

    expect([zombie.power, zombie.toughness]).to eq([4, 2])
  end

  it "exiles up to two cards from one graveyard, draining if one was a creature" do
    p2.graveyard.add(their_creature)
    p2.graveyard.add(their_spell)
    enter!
    game.resolve_choice!(targets: [their_creature, their_spell])

    expect([their_creature, their_spell].map(&:zone)).to all(be_exile)
    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end

  it "doesn't drain when no creature card was exiled" do
    p2.graveyard.add(their_spell)
    p2.graveyard.add(their_creature)
    enter!
    game.resolve_choice!(targets: [their_spell])

    expect(their_spell.zone).to be_exile
    expect(their_creature.zone).to be_graveyard
    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end

  it "can exile from your own graveyard" do
    p1.graveyard.add(my_creature)
    p2.graveyard.add(their_spell)
    enter!
    game.resolve_choice!(targets: [my_creature])

    expect(my_creature.zone).to be_exile
    expect(p2.life).to eq(18)
  end

  it "may choose no targets" do
    p2.graveyard.add(their_creature)
    p2.graveyard.add(their_spell)
    enter!
    game.skip_choice!

    expect(their_creature.zone).to be_graveyard
    expect(p2.life).to eq(20)
  end

  it "rejects targets from two different graveyards" do
    p1.graveyard.add(my_creature)
    p2.graveyard.add(their_creature)
    enter!

    expect { game.choices.last.resolve!(targets: [my_creature, their_creature]) }.to raise_error(ArgumentError, /single graveyard/)
  end
end
