# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GuardianOfTheForgotten do
  include_context "two player game"

  let!(:guardian) { ResolvePermanent("Guardian Of The Forgotten", owner: p1) }
  let!(:top_card) { Card("Forest", owner: p1).tap { p1.library.add(_1) } }

  it "is a 4/4 Elephant Warrior with vigilance" do
    expect([guardian.power, guardian.toughness]).to eq([4, 4])
    expect(guardian.type?("Elephant")).to be(true)
    expect(guardian).to have_keyword(:vigilance)
  end

  context "when a modified creature you control dies" do
    it "manifests the top card of your library (counter)" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter("+1/+1")
      bears.destroy!
      game.settle!

      manifested = p1.permanents.select(&:face_down?)
      expect(manifested.size).to eq(1)
      expect(manifested.first.card).to eq(top_card)
      expect([manifested.first.power, manifested.first.toughness]).to eq([2, 2])
      expect(p1.library.cards).not_to include(top_card)
    end

    it "manifests when Guardian itself is modified and dies" do
      guardian.add_counter("+1/+1")
      guardian.destroy!
      game.settle!

      expect(p1.permanents.count(&:face_down?)).to eq(1)
    end

    it "manifests when the dying creature had Equipment attached" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      greaves = ResolvePermanent("Lightning Greaves", owner: p1)
      go_to_main_phase!
      p1.activate_ability(ability: greaves.activated_abilities.first) { _1.targeting(bears) }
      game.stack.resolve!
      game.tick!
      top = Card("Forest", owner: p1).tap { p1.library.add(_1) }
      bears.destroy!
      game.settle!

      expect(p1.permanents.select(&:face_down?).map(&:card)).to eq([top])
    end

    it "does not manifest for an unmodified creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.destroy!
      game.settle!

      expect(p1.permanents.count(&:face_down?)).to eq(0)
    end

    it "does not manifest for an opponent's modified creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs.add_counter("+1/+1")
      theirs.destroy!
      game.settle!

      expect(p1.permanents.count(&:face_down?)).to eq(0)
      expect(p2.permanents.count(&:face_down?)).to eq(0)
    end
  end
end
