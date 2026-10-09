# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LongBodiedGreyDog do
  include_context "two player game"

  it "has flash and reach" do
    dog = Card("Long Bodied Grey Dog", owner: p1)
    expect(dog.keywords).to include(Magic::Cards::Keywords::FLASH, Magic::Cards::Keywords::REACH)
  end

  it "creates a tapped Treasure token when it enters" do
    ResolvePermanent("Long Bodied Grey Dog", owner: p1)
    treasure = p1.permanents.by_name("Treasure").first
    expect(treasure).not_to be_nil
    expect(treasure).to be_tapped
  end
end
