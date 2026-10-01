# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JeskaiBrushmaster do
  include_context "two player game"

  let!(:brushmaster) { ResolvePermanent("Jeskai Brushmaster", owner: p1) }

  it "is a 2/4 with double strike" do
    expect(brushmaster.power).to eq(2)
    expect(brushmaster.toughness).to eq(4)
    expect(brushmaster.has_keyword?(Magic::Cards::Keywords::DOUBLE_STRIKE)).to eq(true)
  end

  it "gets +1/+1 when you cast a noncreature spell" do
    p1.add_mana(green: 2)
    cast_action(player: p1, card: Card("Rampant Growth"))
      .pay_mana(green: 1, generic: { green: 1 })
      .perform
    game.settle!

    expect(brushmaster.power).to eq(3)
    expect(brushmaster.toughness).to eq(5)
  end

  it "does not get +1/+1 for a creature spell" do
    p1.add_mana(green: 2)
    cast_action(player: p1, card: Card("Grizzly Bears"))
      .pay_mana(green: 1, generic: { green: 1 })
      .perform
    game.settle!

    expect(brushmaster.power).to eq(2)
  end
end
