# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Anger do
  include_context "two player game"

  subject!(:anger) { ResolvePermanent("Anger", owner: p1) }

  before { game.tick! }

  it "is a 2/2 Incarnation with haste" do
    expect(anger.power).to eq(2)
    expect(anger.toughness).to eq(2)
    expect(anger).to be_type("Incarnation")
    expect(anger.has_keyword?(:haste)).to eq(true)
  end

  context "when in your graveyard and you control a Mountain" do
    let!(:mountain) { ResolvePermanent("Mountain", owner: p1) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    before do
      anger.card.move_to_graveyard!
      game.tick!
    end

    it "gives creatures you control haste" do
      expect(wood_elves.has_keyword?(:haste)).to eq(true)
    end

    it "does not give haste to opponents' creatures" do
      opponent_elves = ResolvePermanent("Wood Elves", owner: p2)
      game.tick!

      expect(opponent_elves.has_keyword?(:haste)).to eq(false)
    end
  end

  context "when in your graveyard but you do not control a Mountain" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    before do
      anger.card.move_to_graveyard!
      game.tick!
    end

    it "does not give creatures you control haste" do
      expect(wood_elves.has_keyword?(:haste)).to eq(false)
    end
  end

  context "when still on the battlefield (not in your graveyard)" do
    let!(:mountain) { ResolvePermanent("Mountain", owner: p1) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    before { game.tick! }

    it "does not give other creatures you control haste" do
      expect(wood_elves.has_keyword?(:haste)).to eq(false)
    end
  end
end
