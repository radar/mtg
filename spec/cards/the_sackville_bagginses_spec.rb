# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheSackvilleBagginses do
  include_context "two player game"

  def treasures = p1.permanents.select { _1.type?("Treasure") }

  it "may sacrifice another creature to draw a card and make a Treasure" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("The Sackville-Bagginses", owner: p1)
    library_before = p1.library.count
    game.resolve_choice!(sacrifice: bears)
    game.settle!

    expect(bears.card.zone).to be_graveyard
    expect(p1.library.count).to eq(library_before - 1)
    expect(treasures.count).to eq(1)
  end

  it "can sacrifice an artifact" do
    spatula = ResolvePermanent("Well-Worn Spatula", owner: p1)
    ResolvePermanent("The Sackville-Bagginses", owner: p1)
    game.resolve_choice!(sacrifice: spatula)
    game.settle!

    expect(spatula.card.zone).to be_graveyard
    expect(treasures.count).to eq(1)
  end

  it "does nothing if the sacrifice is declined" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("The Sackville-Bagginses", owner: p1)
    game.skip_choice!
    game.settle!

    expect(treasures).to be_empty
  end

  it "makes an opponent lose 1 life whenever you sacrifice a token (the Treasure)" do
    ResolvePermanent("The Sackville-Bagginses", owner: p1)
    treasure = Magic::Tokens::Treasure.new(game: game, owner: p1).resolve!
    treasure = p1.permanents.find { _1.type?("Treasure") }
    treasure.sacrifice!
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "does not trigger for an opponent's token" do
    ResolvePermanent("The Sackville-Bagginses", owner: p1)
    Magic::Tokens::Treasure.new(game: game, owner: p2).resolve!
    p2.permanents.find { _1.type?("Treasure") }.sacrifice!
    game.settle!

    expect(p2.life).to eq(20)
  end
end
