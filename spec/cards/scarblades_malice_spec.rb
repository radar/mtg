# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScarbladesMalice do
  include_context "two player game"

  let(:card) { Card("Scarblade's Malice", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_on(creature)
    p1.hand.add(card)
    p1.add_mana(black: 1)
    p1.cast(card:) { _1.pay_mana(black: 1).targeting(creature) }
    game.stack.resolve!
    game.tick!
  end

  it "gives the creature deathtouch and lifelink until end of turn" do
    cast_on(bears)

    expect(bears).to be_deathtouch
    expect(bears).to be_lifelink
  end

  it "can only target a creature you control" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.hand.add(card)
    p1.add_mana(black: 1)

    expect { p1.cast(card:) { _1.pay_mana(black: 1).targeting(theirs) } }.to raise_error(StandardError)
  end

  it "creates a 2/2 black and green Elf when that creature dies this turn" do
    cast_on(bears)
    bears.destroy!
    game.settle!
    elf = p1.creatures.find { _1.name == "Elf" }

    expect([elf.power, elf.toughness]).to eq([2, 2])
    expect(elf.colors).to contain_exactly(:black, :green)
  end

  it "does not create an Elf if the creature dies without the spell" do
    bears.destroy!
    game.settle!

    expect(p1.creatures).to be_empty
  end

  it "does not create an Elf when another creature dies" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_on(bears)
    other.destroy!
    game.settle!

    expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
  end

  it "the delayed trigger ends with the turn" do
    cast_on(bears)
    current_turn.end!
    current_turn.cleanup!
    bears.destroy!
    game.settle!

    expect(p1.creatures.map(&:name)).not_to include("Elf")
  end
end
