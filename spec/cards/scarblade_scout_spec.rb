# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScarbladeScout do
  include_context "two player game"

  let(:top_two) { p1.library.first(2) }

  it "is a 2/2 Elf Scout with lifelink" do
    scout = ResolvePermanent("Scarblade Scout", owner: p1)
    expect(scout.power).to eq(2)
    expect(scout.toughness).to eq(2)
    expect(scout.type?("Elf")).to eq(true)
    expect(scout.type?("Scout")).to eq(true)
    expect(scout.lifelink?).to eq(true)
  end

  it "mills two cards when it enters" do
    milled = top_two
    expect { ResolvePermanent("Scarblade Scout", owner: p1) }.to change { p1.library.count }.by(-2)
    expect(p1.graveyard.cards).to include(*milled)
  end

  it "doesn't mill the opponent" do
    expect { ResolvePermanent("Scarblade Scout", owner: p1) }.not_to(change { p2.library.count })
  end
end
