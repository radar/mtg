# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SummitSentinel do
  include_context "two player game"

  let!(:sentinel) { ResolvePermanent("Summit Sentinel", owner: p1) }

  it "is a 1/3 elemental soldier" do
    expect(sentinel.card.types).to include("Elemental", "Soldier")
    expect(sentinel.power).to eq(1)
    expect(sentinel.toughness).to eq(3)
  end

  it "draws a card when it dies" do
    library_count = p1.library.count
    sentinel.destroy!
    game.settle!

    expect(p1.library.count).to eq(library_count - 1)
  end
end
