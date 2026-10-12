# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpineseekerCentipede do
  include_context "two player game"

  subject(:centipede) { ResolvePermanent("Spineseeker Centipede", owner: p1) }

  def fill_graveyard_with_types(*names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  it "is a 2/1 Insect" do
    expect(centipede.power).to eq(2)
    expect(centipede.toughness).to eq(1)
    expect(centipede.type?("Insect")).to be true
    expect(centipede.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to be false
  end

  it "searches for a basic land when it enters" do
    forest = Card("Forest", owner: p1)
    p1.library.add(forest)
    centipede
    expect(game.choices.first).to be_a(described_class::BasicLandChoice)
    game.resolve_choice!(target: forest)
    expect(p1.hand.cards).to include(forest)
  end

  context "delirium" do
    before { game.skip_choice! if centipede && game.choices.any? }

    it "gets nothing with fewer than four card types in the graveyard" do
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")
      game.tick!
      expect(centipede.power).to eq(2)
      expect(centipede.toughness).to eq(1)
      expect(centipede.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to be false
    end

    it "gets +1/+2 and vigilance with four card types in the graveyard" do
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")
      game.tick!
      expect(centipede.power).to eq(3)
      expect(centipede.toughness).to eq(3)
      expect(centipede.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to be true
    end
  end
end
