# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AmbushWolf do
  include_context "two player game"

  let(:mine) { Card("Grizzly Bears", owner: p1) }
  let(:theirs) { Card("Boltwave", owner: p2) }

  it "is a 4/2 Wolf with flash" do
    wolf = ResolvePermanent("Ambush Wolf", owner: p1)

    expect([wolf.power, wolf.toughness]).to eq([4, 2])
    expect(wolf.card).to be_flash
  end

  it "exiles a card from any graveyard when it enters" do
    p1.graveyard.add(mine)
    p2.graveyard.add(theirs)
    ResolvePermanent("Ambush Wolf", owner: p1, settle: false)
    game.settle!
    game.resolve_choice!(target: theirs)

    expect(theirs.zone).to be_exile
    expect(mine.zone).to be_graveyard
  end

  it "may exile nothing" do
    p1.graveyard.add(mine)
    p2.graveyard.add(theirs)
    ResolvePermanent("Ambush Wolf", owner: p1, settle: false)
    game.settle!
    game.skip_choice!

    expect(mine.zone).to be_graveyard
    expect(theirs.zone).to be_graveyard
  end

  it "does nothing with empty graveyards" do
    ResolvePermanent("Ambush Wolf", owner: p1)

    expect(game.choices).to be_empty
  end
end
