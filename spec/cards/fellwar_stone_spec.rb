# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FellwarStone do
  include_context "two player game"

  let!(:stone) { ResolvePermanent("Fellwar Stone", owner: p1) }

  it "makes no mana when the opponent controls no land" do
    expect(stone.activated_abilities.first.choices).to be_empty
  end

  it "makes any colour an opponent's land could produce" do
    ResolvePermanent("Forest", owner: p2)
    ResolvePermanent("Shivan Reef", owner: p2)

    expect(stone.activated_abilities.first.choices).to contain_exactly(:green, :blue, :red)
  end

  it "does not count colourless" do
    ResolvePermanent("Shivan Reef", owner: p2)

    expect(stone.activated_abilities.first.choices).not_to include(:colorless)
  end

  it "taps for a chosen colour" do
    ResolvePermanent("Island", owner: p2)
    p1.activate_ability(ability: stone.activated_abilities.first) { |a| a.choose(:blue) }

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "ignores its controller's own lands" do
    ResolvePermanent("Forest", owner: p1)

    expect(stone.activated_abilities.first.choices).to be_empty
  end
end
