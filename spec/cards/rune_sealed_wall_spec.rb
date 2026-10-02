# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RuneSealedWall do
  include_context "two player game"

  let!(:wall) { ResolvePermanent("Rune-Sealed Wall", owner: p1) }

  it "is a 0/6 artifact Wall with defender" do
    expect([wall.power, wall.toughness]).to eq([0, 6])
    expect(wall).to be_artifact
    expect(wall).to be_defender
  end

  it "taps to surveil 1" do
    p1.activate_ability(ability: wall.activated_abilities.first)
    game.stack.resolve!
    top = p1.library.first
    game.resolve_choice!(graveyard: [top])

    expect(wall).to be_tapped
    expect(top.zone).to be_graveyard
  end

  it "can keep the card on top" do
    p1.activate_ability(ability: wall.activated_abilities.first)
    game.stack.resolve!
    top = p1.library.first
    game.resolve_choice!(top: [top])

    expect(p1.library.first).to eq(top)
  end
end
