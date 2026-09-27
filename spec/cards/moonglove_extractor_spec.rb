# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoongloveExtractor do
  include_context "two player game"

  let!(:extractor) { ResolvePermanent("Moonglove Extractor", owner: p1) }

  it "is a 2/1 elf warlock" do
    expect(extractor.card.types).to include("Elf", "Warlock")
    expect(extractor.power).to eq(2)
    expect(extractor.toughness).to eq(1)
  end

  it "draws a card and loses 1 life when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    library_count = p1.library.count

    p1.declare_attacker(attacker: extractor, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(p1.library.count).to eq(library_count - 1)
    expect(p1.life).to eq(19)
  end
end
