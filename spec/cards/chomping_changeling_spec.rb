# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChompingChangeling do
  include_context "two player game"

  it "is a 1/2 Changeling" do
    changeling = ResolvePermanent("Chomping Changeling", owner: p1, settle: false)

    expect([changeling.power, changeling.toughness]).to eq([1, 2])
    expect(changeling.type?("Elf")).to be(true)
  end

  it "destroys up to one target artifact or enchantment when it enters" do
    stone = ResolvePermanent("Mind Stone", owner: p2)
    ResolvePermanent("Chomping Changeling", owner: p1)
    game.resolve_choice!(target: stone)

    expect(stone.card.zone).to be_graveyard
  end

  it "may destroy nothing" do
    stone = ResolvePermanent("Mind Stone", owner: p2)
    ResolvePermanent("Chomping Changeling", owner: p1)
    game.skip_choice!

    expect(stone.zone).to be_battlefield
  end

  it "does nothing without an artifact or enchantment to target" do
    ResolvePermanent("Chomping Changeling", owner: p1)

    expect(game.choices).to be_empty
  end
end
