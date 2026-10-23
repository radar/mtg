# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IndebtedSpirit do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_bestowed(target)
    p1.add_mana(white: 3)
    p1.cast_as(:bestowed, card: Card("Indebted Spirit", owner: p1)) { |a| a.pay_mana(generic: { white: 2 }, white: 1).targeting(target) }
  end

  def spirits = p1.creatures.select { _1.name == "Spirit" }

  it "creates a 1/1 white and black flying Spirit when it dies" do
    spirit = ResolvePermanent("Indebted Spirit", owner: p1)
    spirit.destroy!
    game.settle!

    expect(spirits.count).to eq(1)
    expect(spirits.first.power).to eq(1)
    expect(spirits.first.flying?).to eq(true)
    expect(spirits.first.colors).to match_array(%i[white black])
  end

  context "when bestowed" do
    before do
      go_to_main_phase!
      cast_bestowed(bears)
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "gives the enchanted creature +1/+1" do
      expect(bears.power).to eq(3)
      expect(bears.toughness).to eq(3)
    end

    it "gives the enchanted creature afterlife 1" do
      bears.destroy!
      game.settle!

      expect(spirits.count).to eq(1)
    end
  end
end
