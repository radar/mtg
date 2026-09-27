# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BileVialBoggart do
  include_context "two player game"

  let!(:boggart) { ResolvePermanent("Bile-Vial Boggart", owner: p1) }

  it "is a 1/1 goblin assassin" do
    expect(boggart.card.types).to include("Goblin", "Assassin")
    expect(boggart.power).to eq(1)
    expect(boggart.toughness).to eq(1)
  end

  it "puts a -1/-1 counter on up to one target creature when it dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    boggart.destroy!
    game.settle!

    game.resolve_choice!(target: bears)

    expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end

  it "may be declined (up to one)" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    boggart.destroy!
    game.settle!

    game.skip_choice!

    expect(game.choices).to be_empty
  end
end
