# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AngelOfFinality do
  include_context "two player game"

  let(:mine) { Card("Grizzly Bears", owner: p1) }
  let(:theirs) { Card("Boltwave", owner: p2) }
  let(:theirs_two) { Card("Grizzly Bears", owner: p2) }

  it "is a 3/4 flying Angel" do
    angel = ResolvePermanent("Angel Of Finality", owner: p1)

    expect([angel.power, angel.toughness]).to eq([3, 4])
    expect(angel.has_keyword?(:flying)).to eq(true)
  end

  it "exiles the targeted player's whole graveyard when it enters" do
    p1.graveyard.add(mine)
    p2.graveyard.add(theirs)
    p2.graveyard.add(theirs_two)
    ResolvePermanent("Angel Of Finality", owner: p1, settle: false)
    game.settle!
    game.resolve_choice!(target: p2)

    expect(p2.graveyard.cards).to be_empty
    expect([theirs, theirs_two].map(&:zone)).to all(be_exile)
    expect(mine.zone).to be_graveyard
  end

  it "can exile your own graveyard" do
    p1.graveyard.add(mine)
    p2.graveyard.add(theirs)
    ResolvePermanent("Angel Of Finality", owner: p1, settle: false)
    game.settle!
    game.resolve_choice!(target: p1)

    expect(mine.zone).to be_exile
    expect(theirs.zone).to be_graveyard
  end
end
