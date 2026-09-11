# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Mirrorform do
  include_context "two player game"

  let(:card) { Card("Mirrorform", owner: p1) }

  describe "#target_choices" do
    let!(:setessan_training) { ResolvePermanent("Setessan Training", owner: p1) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:opponent_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "excludes Auras" do
      expect(card.target_choices).not_to include(setessan_training)
    end

    it "includes non-Aura permanents regardless of controller" do
      expect(card.target_choices).to include(wood_elves)
      expect(card.target_choices).to include(opponent_bears)
    end
  end

  describe "#resolve!" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:sol_ring) { ResolvePermanent("Sol Ring", owner: p1) }
    let!(:forest) { ResolvePermanent("Forest", owner: p1) }
    let!(:opponent_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      p1.add_mana(blue: 6)

      p1.cast(card: card) do
        _1.pay_mana(generic: { blue: 4 }, blue: 2)
        _1.targeting(opponent_bears)
      end

      game.stack.resolve!
      game.tick!
    end

    it "turns each nonland permanent you control into a copy of the target" do
      expect(wood_elves.name).to eq("Grizzly Bears")
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)

      expect(sol_ring.name).to eq("Grizzly Bears")
      expect(sol_ring.power).to eq(2)
      expect(sol_ring.toughness).to eq(2)
    end

    it "does not affect lands you control" do
      expect(forest.name).to eq("Forest")
    end

    it "does not affect the target itself or other permanents you don't control" do
      expect(opponent_bears.name).to eq("Grizzly Bears")
      expect(opponent_bears.power).to eq(2)
      expect(opponent_bears.toughness).to eq(2)
    end
  end
end
