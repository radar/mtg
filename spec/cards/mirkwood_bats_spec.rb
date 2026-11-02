# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirkwoodBats do
  include_context "two player game"

  let!(:bats) { ResolvePermanent("Mirkwood Bats", owner: p1) }

  def make_treasure(owner)
    Magic::Tokens::Treasure.new(game: game, owner: owner).resolve!
    game.settle!
    owner.permanents.find { _1.type?("Treasure") }
  end

  it "is a 2/3 flyer" do
    expect([bats.power, bats.toughness]).to eq([2, 3])
    expect(bats).to be_flying
  end

  it "makes each opponent lose 1 life when you create a token" do
    make_treasure(p1)

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "makes each opponent lose 1 life when you sacrifice a token" do
    treasure = make_treasure(p1)
    expect(p2.life).to eq(19)

    treasure.sacrifice!
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "does not trigger for a nontoken permanent entering" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "does not trigger for a nontoken sacrifice" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.sacrifice!
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "does not trigger for tokens the opponent creates or sacrifices" do
    treasure = make_treasure(p2)
    treasure.sacrifice!
    game.settle!

    expect(p2.life).to eq(20)
    expect(game.choices).to be_empty
  end
end
