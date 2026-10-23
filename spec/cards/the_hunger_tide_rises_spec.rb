# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheHungerTideRises do
  include_context "two player game"

  let(:card) { Card("The Hunger Tide Rises", owner: p1) }
  let(:saga) { game.battlefield.by_name("The Hunger Tide Rises").first }

  def insects = p1.creatures.select { _1.name == "Insect" }

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(green: 3)
    p1.cast(card:) { _1.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — creates an Insect" do
    expect(insects.size).to eq(1)
  end

  it "II and III — each create another Insect" do
    next_chapter
    expect(insects.size).to eq(2)
    next_chapter
    expect(insects.size).to eq(3)
  end

  context "chapter IV" do
    let(:big) { Card("Terror Of The Peaks", owner: p1) }
    let(:small) { Card("Grizzly Bears", owner: p1) }

    before do
      p1.library.add(big)
      p1.graveyard.add(small)
      2.times { next_chapter }
      next_chapter
    end

    it "sacrifices creatures, then finds a creature card of at most that mana value" do
      expect(game.choices.last).to be_a(described_class::SacrificeChoice)
      game.resolve_choice!(sacrifices: insects)
      game.settle!

      choice = game.choices.last
      expect(choice.choices).to contain_exactly(small)
      game.resolve_choice!(target: small)
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p1.graveyard.cards).not_to include(small)
    end

    it "puts a creature found in the library onto the battlefield and shuffles" do
      from_library = Card("Grizzly Bears", owner: p1)
      p1.library.add(from_library)
      game.resolve_choice!(sacrifices: insects)
      game.settle!

      choice = game.choices.last
      expect(choice.choices).to contain_exactly(small, from_library)
      expect(p1.library).to receive(:shuffle!)
      game.resolve_choice!(target: from_library)
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p1.library.cards).not_to include(from_library)
      expect(p1.graveyard.cards).to include(small)
    end

    it "does not shuffle when the creature comes from the graveyard" do
      game.resolve_choice!(sacrifices: insects)
      game.settle!

      expect(p1.library).not_to receive(:shuffle!)
      game.resolve_choice!(target: small)
      game.settle!
    end

    it "finds nothing if no creatures are sacrificed" do
      game.skip_choice!
      game.settle!
      game.skip_choice!

      expect(p1.creatures.map(&:name)).not_to include("Grizzly Bears")
    end
  end
end
