# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WellWornSpatula do
  include_context "two player game"

  let(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gains 2 life when it enters" do
    ResolvePermanent("Well-Worn Spatula", owner: p1)

    expect(p1.life).to eq(22)
  end

  it "gives equipped creature +1/+1" do
    spatula = ResolvePermanent("Well-Worn Spatula", owner: p1)
    p1.add_mana(colorless: 1)
    p1.activate_ability(ability: spatula.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { colorless: 1 })
    end
    game.stack.resolve!
    game.tick!

    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(3)
  end
end
