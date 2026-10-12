# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WinterMisanthropicGuide do
  include_context "two player game"

  subject(:winter) { ResolvePermanent("Winter, Misanthropic Guide", owner: p1) }

  def fill_graveyard_with_types(*names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  it "is a legendary 3/4 Human Warlock with ward {2}" do
    expect([winter.power, winter.toughness]).to eq([3, 4])
    expect(winter.legendary?).to be true
    expect(winter.type?("Warlock")).to be true
  end

  it "makes each player draw two cards at the beginning of its controller's upkeep" do
    winter
    p1_before = p1.hand.count
    p2_before = p2.hand.count
    current_turn.untap!
    current_turn.upkeep!
    game.settle!

    expect(p1.hand.count).to eq(p1_before + 2)
    expect(p2.hand.count).to eq(p2_before + 2)
  end

  it "leaves maximum hand size alone without delirium" do
    winter
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")
    expect(p2.maximum_hand_size).to eq(7)
  end

  it "sets each opponent's maximum hand size to seven minus the card types with delirium" do
    winter
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")
    expect(p2.maximum_hand_size).to eq(3)
    expect(p1.maximum_hand_size).to eq(7)
  end
end
