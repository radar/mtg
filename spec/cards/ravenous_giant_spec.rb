# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RavenousGiant do
  include_context "two player game"

  let!(:giant) { ResolvePermanent("Ravenous Giant", owner: p1) }

  it "is a 5/5 Giant" do
    expect([giant.power, giant.toughness]).to eq([5, 5])
  end

  it "deals 1 damage to you at the beginning of your upkeep" do
    go_to_main_phase!

    expect(p1.life).to eq(19)
  end

  it "doesn't trigger on an opponent's upkeep" do
    go_to_main_phase_for!(p2)

    expect(p1.life).to eq(20)
  end
end
