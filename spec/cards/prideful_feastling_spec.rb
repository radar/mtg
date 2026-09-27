# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PridefulFeastling do
  include_context "two player game"

  let!(:feastling) { ResolvePermanent("Prideful Feastling", owner: p1) }

  it "is a 2/3 shapeshifter" do
    expect(feastling.power).to eq(2)
    expect(feastling.toughness).to eq(3)
  end

  it "has changeling" do
    expect(feastling.card.changeling?).to be(true)
    expect(feastling.card.type?("Human")).to be(true)
  end

  it "has lifelink" do
    expect(feastling.lifelink?).to be(true)
  end
end
