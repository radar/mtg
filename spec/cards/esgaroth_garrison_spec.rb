# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EsgarothGarrison do
  include_context "two player game"

  let!(:garrison) { ResolvePermanent("Esgaroth Garrison", owner: p1) }

  it "has power equal to the number of creatures you control, and toughness 5" do
    game.tick!
    expect([garrison.power, garrison.toughness]).to eq([1, 5])
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!
    expect(garrison.power).to eq(2)
  end

  it "recruits when it enters: draws, discards, and makes a Human Soldier for a nonland discard" do
    expect(game.choices.last).to be_a(Magic::Recruit::DiscardChoice)
    spell = Card("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    game.resolve_choice!(card: spell)
    game.tick!

    expect(p1.graveyard.cards).to include(spell)
    soldier = p1.creatures.find { _1.type?("Human") && _1.type?("Soldier") && _1.token? }
    expect(soldier).not_to be_nil
    expect([soldier.power, soldier.toughness]).to eq([1, 1])
    expect(garrison.power).to eq(2)
  end

  it "makes no token when a land is discarded" do
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    game.resolve_choice!(card: land)
    expect(p1.creatures.count { _1.token? }).to eq(0)
  end
end
