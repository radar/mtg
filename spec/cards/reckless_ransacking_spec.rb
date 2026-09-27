# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RecklessRansacking do
  include_context "two player game"

  it "gives target creature +3/+2 until end of turn and creates a Treasure token" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 2)

    p1.cast(card: Card("Reckless Ransacking", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.power).to eq(5)
    expect(bears.toughness).to eq(4)
    expect(p1.permanents.select { |permanent| permanent.name == "Treasure" }.count).to eq(1)
  end
end
