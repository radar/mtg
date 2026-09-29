# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NoggleTheMind do
  include_context "two player game"

  let(:card) { Card("Noggle The Mind", owner: p1) }

  def enchant(creature)
    p1.hand.add(card)
    p1.add_mana(blue: 2)
    p1.cast(card:) { _1.pay_mana(generic: { blue: 1 }, blue: 1).targeting(creature) }
    game.stack.resolve!
    game.tick!
  end

  it "has flash" do
    expect(card.flash?).to be(true)
  end

  it "makes the creature a colorless 1/1 Noggle" do
    courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
    enchant(courser)

    expect([courser.power, courser.toughness]).to eq([1, 1])
    expect(courser.colors).to be_empty
    expect(courser.type?("Noggle")).to be(true)
    expect(courser.type?("Elf")).to be(false)
  end

  it "makes the creature lose all abilities" do
    flyer = ResolvePermanent("Shinestriker", owner: p2)
    game.tick!
    expect(flyer).to be_flying
    enchant(flyer)

    expect(flyer).not_to be_flying
  end

  it "can be cast at instant speed" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    enchant(bears) # the two player game leaves turn 1 in the beginning step

    expect(bears.power).to eq(1)
  end

  it "wears off when the Aura leaves" do
    courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
    enchant(courser)
    p1.permanents.find { _1.name == "Noggle the Mind" }.destroy!
    game.settle!
    game.tick!

    expect(courser.power).to eq(2)
  end
end
