# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CrowOfDarkTidings do
  include_context "two player game"

  it "is a 2/1 flyer" do
    crow = ResolvePermanent("Crow Of Dark Tidings", owner: p1)

    expect([crow.power, crow.toughness]).to eq([2, 1])
    expect(crow).to be_flying
  end

  it "mills two cards when it enters" do
    library_size = p1.library.count
    ResolvePermanent("Crow Of Dark Tidings", owner: p1)

    expect(p1.library.count).to eq(library_size - 2)
  end

  it "mills two more cards when it dies" do
    crow = ResolvePermanent("Crow Of Dark Tidings", owner: p1)
    library_size = p1.library.count
    crow.destroy!
    game.settle!

    expect(p1.library.count).to eq(library_size - 2)
  end
end
