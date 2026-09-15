# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImpactTremors do
  include_context "two player game"

  let!(:impact_tremors) { ResolvePermanent("Impact Tremors", owner: p1) }

  it "deals 1 damage to each opponent when a creature you control enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(p2.life).to eq(19)
  end

  it "doesn't trigger when an opponent's creature enters" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(p2.life).to eq(20)
  end

  it "doesn't trigger when a noncreature permanent you control enters" do
    ResolvePermanent("Impact Tremors", owner: p1)

    expect(p2.life).to eq(20)
  end
end
