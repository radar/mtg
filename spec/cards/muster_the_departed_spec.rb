# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MusterTheDeparted do
  include_context "two player game"

  before { go_to_main_phase! }

  def spirits = p1.creatures.select { _1.name == "Spirit" }

  context "when it enters" do
    it "creates a 1/1 white Spirit with flying" do
      ResolvePermanent("Muster The Departed", owner: p1)

      expect(spirits.size).to eq(1)
      expect([spirits.first.power, spirits.first.toughness]).to eq([1, 1])
      expect(spirits.first).to have_keyword(:flying)
      expect(spirits.first.colors).to eq([:white])
    end
  end

  context "at the beginning of your end step" do
    let!(:muster) { ResolvePermanent("Muster The Departed", owner: p1) }

    def end_turn!
      current_turn.end!
      game.settle!
    end

    it "populates if a creature died this turn" do
      victim = ResolvePermanent("Grizzly Bears", owner: p2)
      victim.destroy!
      game.settle!

      expect { end_turn! }.to change { spirits.size }.from(1).to(2)
    end

    it "does nothing if no creature died this turn" do
      expect { end_turn! }.not_to change { spirits.size }
    end
  end
end
