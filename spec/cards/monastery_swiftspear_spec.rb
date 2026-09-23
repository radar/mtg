# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MonasterySwiftspear do
  include_context "two player game"

  subject!(:swiftspear) { ResolvePermanent("Monastery Swiftspear", owner: p1) }

  it "is a 1/2 Human Monk with haste" do
    expect(swiftspear.power).to eq(1)
    expect(swiftspear.toughness).to eq(2)
    expect(swiftspear.has_keyword?(:haste)).to eq(true)
  end

  it "gets +1/+1 until end of turn when you cast a noncreature spell" do
    p1.add_mana(red: 1)
    action = cast_action(player: p1, card: Card("Lightning Bolt", owner: p1))
      .pay_mana(red: 1)
    action.targeting(p2)
    action.perform
    game.settle!

    expect(swiftspear.power).to eq(2)
    expect(swiftspear.toughness).to eq(3)
    expect(swiftspear.modifiers).to all(be_until_eot)
  end

  it "doesn't get boosted when you cast a creature spell" do
    p1.add_mana(green: 2)
    action = cast_action(player: p1, card: Card("Grizzly Bears", owner: p1))
      .pay_mana(generic: { green: 1 }, green: 1)
    action.perform
    game.settle!

    expect(swiftspear.power).to eq(1)
    expect(swiftspear.toughness).to eq(2)
  end
end
