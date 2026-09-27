# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GanglyStompling do
  include_context "two player game"

  let!(:stompling) { ResolvePermanent("Gangly Stompling", owner: p1) }

  it "is a 4/2 shapeshifter" do
    expect(stompling.power).to eq(4)
    expect(stompling.toughness).to eq(2)
  end

  it "has changeling" do
    expect(stompling.card.changeling?).to be(true)
    expect(stompling.card.type?("Elf")).to be(true)
  end

  it "has trample" do
    expect(stompling.trample?).to be(true)
  end
end
