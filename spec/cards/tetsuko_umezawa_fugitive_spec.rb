# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TetsukoUmezawaFugitive do
  include_context "two player game"

  let!(:tetsuko) { ResolvePermanent("Tetsuko Umezawa, Fugitive", owner: p1) }

  it "makes a creature with power 1 or less unblockable" do
    small = ResolvePermanent("Ornithopter Of Paradise", owner: p1)
    game.tick!
    expect(small.power).to be <= 1

    expect(small).to have_keyword(:cant_be_blocked)
  end

  it "makes a creature with toughness 1 or less unblockable" do
    small = ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    expect(small).to have_keyword(:cant_be_blocked)
  end

  it "does not affect a bigger creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(bears).not_to have_keyword(:cant_be_blocked)
  end

  it "does not affect an opponent's small creature" do
    elves = ResolvePermanent("Llanowar Elves", owner: p2)
    game.tick!

    expect(elves).not_to have_keyword(:cant_be_blocked)
  end

  it "applies to itself, having toughness 3 but power 1" do
    game.tick!
    expect(tetsuko).to have_keyword(:cant_be_blocked)
  end
end
