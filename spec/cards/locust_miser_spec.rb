# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LocustMiser do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:miser) { ResolvePermanent("Locust Miser", owner: p1) }

  it "is a 2/2" do
    expect([miser.power, miser.toughness]).to eq([2, 2])
  end

  it "reduces each opponent's maximum hand size by two" do
    expect(p2.maximum_hand_size).to eq(5)
  end

  it "does not reduce its controller's maximum hand size" do
    expect(p1.maximum_hand_size).to eq(7)
  end

  it "stacks with a second copy" do
    ResolvePermanent("Locust Miser", owner: p1)

    expect(p2.maximum_hand_size).to eq(3)
  end

  it "stops applying when it leaves the battlefield" do
    miser.destroy!
    game.settle!

    expect(p2.maximum_hand_size).to eq(7)
  end

  it "does not override having no maximum hand size" do
    ResolvePermanent("Curiosity Crafter", owner: p2)

    expect(p2.maximum_hand_size).to be_nil
  end
end
