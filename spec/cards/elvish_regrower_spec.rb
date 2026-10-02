# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvishRegrower do
  include_context "two player game"

  let(:dead_bears) { Card("Grizzly Bears", owner: p1) }
  let(:dead_bolt) { Card("Boltwave", owner: p1) }

  it "is a 4/3 Elf Druid" do
    regrower = ResolvePermanent("Elvish Regrower", owner: p1)

    expect([regrower.power, regrower.toughness]).to eq([4, 3])
  end

  it "returns a permanent card from your graveyard to your hand" do
    p1.graveyard.add(dead_bears)
    p1.graveyard.add(Card("Bear Cub", owner: p1))
    ResolvePermanent("Elvish Regrower", owner: p1)
    game.resolve_choice!(target: dead_bears)

    expect(dead_bears.zone).to be_hand
  end

  it "can't return a nonpermanent card" do
    p1.graveyard.add(dead_bolt)
    p1.graveyard.add(dead_bears)
    p1.graveyard.add(Card("Bear Cub", owner: p1))
    ResolvePermanent("Elvish Regrower", owner: p1)

    expect(game.choices.last.choices).not_to include(dead_bolt)
  end
end
