# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HumblingElder do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  # With a single legal target the engine targets it automatically.
  let!(:elder) { ResolvePermanent("Humbling Elder", owner: p1) }

  it "is a 1/2 with flash" do
    expect([elder.power, elder.toughness]).to eq([1, 2])
    expect(elder.has_keyword?(Magic::Cards::Keywords::FLASH)).to eq(true)
  end

  it "gives the opposing creature -2/-0 until end of turn, and not its controller's creatures" do
    expect(bears.power).to eq(0)
    expect(bears.toughness).to eq(2)
    expect(mine.power).to eq(2)

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.power).to eq(2)
  end

  it "lets you choose when there are several opposing creatures" do
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Humbling Elder", owner: p1)
    expect(game.choices.last.choices).to contain_exactly(bears, other)
    game.resolve_choice!(target: other)
    expect(other.power).to eq(0)
    expect(bears.power).to eq(0) # still weakened by the first Elder
  end
end
