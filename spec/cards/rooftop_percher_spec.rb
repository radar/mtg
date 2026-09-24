# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RooftopPercher do
  include_context "two player game"

  let!(:mine) { Card("Island", owner: p1).tap { |c| p1.graveyard.add(c) } }
  let!(:theirs) { Card("Island", owner: p2).tap { |c| p2.graveyard.add(c) } }
  let!(:extra) { Card("Island", owner: p1).tap { |c| p1.graveyard.add(c) } }

  it "is a 3/3 flying changeling" do
    percher = ResolvePermanent("Rooftop Percher", owner: p1, settle: false)
    expect(percher.power).to eq(3)
    expect(percher.toughness).to eq(3)
    expect(percher).to be_flying
    expect(percher.type?("Shapeshifter")).to be true
    expect(percher.type?("Elf")).to be true
  end

  it "exiles up to two target cards from graveyards and gains 3 life" do
    ResolvePermanent("Rooftop Percher", owner: p1)
    choice = game.choices.last
    expect(choice.choices).to include(mine, theirs, extra)

    game.resolve_choice!(targets: [mine, theirs])

    expect(mine.zone).to eq(game.exile)
    expect(theirs.zone).to eq(game.exile)
    expect(extra.zone).to eq(p1.graveyard)
    expect(p1.life).to eq(23)
  end

  it "allows choosing no cards" do
    ResolvePermanent("Rooftop Percher", owner: p1)
    game.resolve_choice!(targets: [])
    expect(p1.graveyard.cards).to include(mine, extra)
    expect(p1.life).to eq(23)
  end

  it "still gains 3 life with empty graveyards" do
    [mine, theirs, extra].each { |c| c.zone.remove(c) }
    ResolvePermanent("Rooftop Percher", owner: p1)
    expect(game.choices).to be_empty
    expect(p1.life).to eq(23)
  end
end
