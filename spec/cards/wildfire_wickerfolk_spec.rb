# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WildfireWickerfolk do
  include_context "two player game"

  subject(:wickerfolk) { ResolvePermanent("Wildfire Wickerfolk", owner: p1) }

  def fill_graveyard_with_types(*names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  it "is a 3/2 artifact Scarecrow with haste" do
    expect(wickerfolk.power).to eq(3)
    expect(wickerfolk.toughness).to eq(2)
    expect(wickerfolk.artifact?).to be true
    expect(wickerfolk.type?("Scarecrow")).to be true
    expect(wickerfolk.has_keyword?(Magic::Cards::Keywords::HASTE)).to be true
    expect(wickerfolk.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to be false
  end

  it "gets nothing with fewer than four card types in the graveyard" do
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")
    game.tick!
    expect(wickerfolk.power).to eq(3)
    expect(wickerfolk.toughness).to eq(2)
    expect(wickerfolk.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to be false
  end

  it "gets +1/+1 and trample with delirium" do
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")
    game.tick!
    expect(wickerfolk.power).to eq(4)
    expect(wickerfolk.toughness).to eq(3)
    expect(wickerfolk.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to be true
  end
end
