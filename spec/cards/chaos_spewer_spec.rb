# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChaosSpewer do
  include_context "two player game"

  it "is a 5/4 goblin warlock" do
    spewer = ResolvePermanent("Chaos Spewer", owner: p1)

    expect(spewer.card.types).to include("Goblin", "Warlock")
    expect(spewer.power).to eq(5)
    expect(spewer.toughness).to eq(4)
  end

  it "pays {2} when its controller chooses to" do
    p1.add_mana(black: 2)
    ResolvePermanent("Chaos Spewer", owner: p1)

    game.resolve_choice!(payment: { black: 2 })

    expect(p1.mana_pool[:black]).to eq(0)
  end

  it "blights 2 when its controller doesn't pay" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Chaos Spewer", owner: p1)

    game.skip_choice!
    game.resolve_choice!(target: bears)

    expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end
end
