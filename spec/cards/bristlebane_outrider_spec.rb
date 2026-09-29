# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BristlebaneOutrider do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:outrider) { ResolvePermanent("Bristlebane Outrider", owner: p1) }

  it "is a 3/5 Kithkin Knight" do
    game.tick!

    expect([outrider.power, outrider.toughness]).to eq([3, 5])
  end

  it "can't be blocked by creatures with power 2 or less" do
    small = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(outrider.can_be_blocked?(small)).to be(false)
  end

  it "can be blocked by creatures with power 3 or more" do
    big = ResolvePermanent("Bristlebane Outrider", owner: p2)

    expect(outrider.can_be_blocked?(big)).to be(true)
  end

  it "gets +2/+0 as long as another creature entered under your control this turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect([outrider.power, outrider.toughness]).to eq([5, 5])
  end

  it "does not get it from an opponent's creature entering" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(outrider.power).to eq(3)
  end

  it "does not get it from itself entering, and loses it next turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.next_turn
    game.next_turn
    go_to_main_phase!
    game.tick!

    expect(outrider.power).to eq(3)
  end
end
