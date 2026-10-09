# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GreatFierceBee do
  include_context "two player game"

  let!(:bee) { ResolvePermanent("Great Fierce Bee", owner: p1) }

  it "is a 2/2 flier" do
    expect(bee.power).to eq(2)
    expect(bee.keywords).to include(Magic::Cards::Keywords::FLYING)
  end

  it "scries 1 when another creature dies" do
    other = ResolvePermanent("Large Bear", owner: p2)
    other.destroy!
    game.settle!
    expect(game.choices.last).to be_a(Magic::Choice::Scry)
  end

  it "scries only once when several creatures die together" do
    a = ResolvePermanent("Large Bear", owner: p1)
    b = ResolvePermanent("Large Bear", owner: p2)
    a.destroy!
    b.destroy!
    game.settle!
    expect(game.choices.count { _1.is_a?(Magic::Choice::Scry) }).to eq(1)
  end

  it "does not scry when it dies itself" do
    bee.destroy!
    game.settle!
    expect(game.choices).to be_empty
  end
end
