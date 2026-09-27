# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MischievousSneakling do
  include_context "two player game"

  let!(:sneakling) { ResolvePermanent("Mischievous Sneakling", owner: p1) }

  it "is a 2/2 shapeshifter" do
    expect(sneakling.power).to eq(2)
    expect(sneakling.toughness).to eq(2)
  end

  it "has changeling" do
    expect(sneakling.card.changeling?).to be(true)
    expect(sneakling.card.type?("Merfolk")).to be(true)
  end

  it "has flash" do
    expect(sneakling.card.flash?).to be(true)
  end
end
