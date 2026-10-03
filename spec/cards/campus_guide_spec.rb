# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CampusGuide do
  include_context "two player game"

  let!(:land) { Card("Island", owner: p1).tap { p1.library.add(_1) } }
  let!(:nonland) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }

  it "is a 2/1 artifact Golem" do
    guide = ResolvePermanent("Campus Guide", owner: p1, settle: false)

    expect([guide.power, guide.toughness]).to eq([2, 1])
    expect(guide.type?("Artifact")).to be(true)
  end

  it "may search for a basic land card and put it on top of your library" do
    ResolvePermanent("Campus Guide", owner: p1)
    game.settle!
    game.resolve_choice!
    search = game.choices.last

    expect(search.choices.to_a).to all(satisfy { _1.land? })
    expect(search.choices.to_a).to include(land)
    game.resolve_choice!(targets: [land])

    expect(p1.library.first).to eq(land)
    expect(p1.library.count(land)).to eq(1)
    expect(land.zone).to be_library
  end

  it "leaves the library alone when declined" do
    ResolvePermanent("Campus Guide", owner: p1)
    game.settle!
    size = p1.library.count
    game.skip_choice!

    expect(p1.library.count).to eq(size)
    expect(p1.library.first).to eq(nonland)
  end
end
