# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StarlightSnare do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p1.add_mana(blue: 3)
    p1.cast(card: Card("Starlight Snare", owner: p1)) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(rival) }
    game.stack.resolve!
    game.settle!
  end

  it "taps the enchanted creature when it enters" do
    expect(rival).to be_tapped
  end

  it "keeps the enchanted creature tapped during its controller's untap step" do
    go_to_main_phase_for!(p2)

    expect(rival).to be_tapped
  end

  it "lets the creature untap once the Aura is gone" do
    snare = p1.permanents.by_name("Starlight Snare").first
    snare.destroy!
    game.settle!
    go_to_main_phase_for!(p1)
    go_to_main_phase_for!(p2)

    expect(rival).not_to be_tapped
  end
end
