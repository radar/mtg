# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FelidarCub do
  include_context "two player game"

  let!(:cub) { ResolvePermanent("Felidar Cub", owner: p1) }
  let!(:anthem) { ResolvePermanent("Anthem Of Champions", owner: p2) }

  it "is a 2/2 Cat Beast" do
    expect([cub.power, cub.toughness]).to eq([2, 2])
  end

  it "sacrifices itself to destroy target enchantment" do
    p1.activate_ability(ability: cub.activated_abilities.first) { _1.targeting(anthem) }
    game.stack.resolve!
    game.tick!

    expect(cub.card.zone).to be_graveyard
    expect(anthem.card.zone).to be_graveyard
  end
end
