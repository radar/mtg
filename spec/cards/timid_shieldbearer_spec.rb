# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TimidShieldbearer do
  include_context "two player game"

  let!(:shieldbearer) { ResolvePermanent("Timid Shieldbearer", owner: p1) }

  it "is a 2/2 kithkin soldier" do
    expect(shieldbearer.card.types).to include("Kithkin", "Soldier")
    expect(shieldbearer.power).to eq(2)
    expect(shieldbearer.toughness).to eq(2)
  end

  it "gives creatures you control +1/+1 until end of turn for {4}{W}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    opponents_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(white: 5)

    p1.activate_ability(ability: shieldbearer.activated_abilities.first) { |a| a.pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!

    expect(shieldbearer.power).to eq(3)
    expect(bears.power).to eq(3)
    expect(opponents_bears.power).to eq(2)
  end
end
