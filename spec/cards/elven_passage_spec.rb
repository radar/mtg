# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvenPassage do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:passage) { ResolvePermanent("Elven Passage", owner: p1) }
  let!(:forest) { Card("Forest", owner: p1) }

  before do
    passage.untap!
    p1.library.add(forest)
  end

  def activate
    p1.activate_ability(ability: passage.activated_abilities.first)
    game.stack.resolve!
    game.tick!
    game.resolve_choice!(targets: [forest])
  end

  def forest_permanent = p1.permanents.find { _1.name == "Forest" }

  it "pays 1 life, sacrifices itself and fetches a tapped basic land" do
    expect { activate }.to change { p1.life }.by(-1)

    expect(p1.graveyard.cards.map(&:name)).to include("Elven Passage")
    expect(forest_permanent).to be_tapped
    expect(game.choices).to be_empty
  end

  context "with an Elf to behold" do
    let!(:elf) { ResolvePermanent("Elven Raft Steerer", owner: p1) }

    it "untaps the land if you behold an Elf" do
      activate
      expect(game.choices.last).to be_a(described_class::BeholdElfChoice)
      game.resolve_choice!(beheld: elf)
      expect(forest_permanent).not_to be_tapped
    end

    it "leaves the land tapped if you decline" do
      activate
      game.skip_choice!
      expect(forest_permanent).to be_tapped
    end
  end
end
