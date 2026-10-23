# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TrickstersElk do
  include_context "two player game"

  let!(:angel) { ResolvePermanent("Serra Angel", owner: p2) }

  def cast_bestowed(target)
    p1.add_mana(green: 2)
    p1.cast_as(:bestowed, card: Card("Trickster's Elk", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(target) }
  end

  def elk = game.battlefield.permanents.find { _1.name == "Trickster's Elk" }

  it "is a 3/3 Elk enchantment creature" do
    creature = ResolvePermanent("Trickster's Elk", owner: p1)

    expect(creature.power).to eq(3)
    expect(creature.toughness).to eq(3)
    expect(creature.creature?).to eq(true)
    expect(creature.enchantment?).to eq(true)
  end

  context "cast for its bestow cost" do
    before do
      go_to_main_phase!
      cast_bestowed(angel)
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "makes the enchanted creature a 3/3 Elk that loses its abilities" do
      expect(elk.attached_to).to eq(angel)
      expect(elk.creature?).to eq(false)
      expect(angel.power).to eq(3)
      expect(angel.toughness).to eq(3)
      expect(angel.flying?).to eq(false)
      expect(angel.colors).to eq([:green])
    end

    it "becomes a 3/3 creature again when the enchanted creature leaves" do
      angel.destroy!
      game.settle!

      expect(elk.creature?).to eq(true)
      expect(elk.power).to eq(3)
      expect(elk.attached_to).to be_nil
    end
  end
end
