# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BirthingRitual do
  include_context "two player game"

  let!(:ritual) { ResolvePermanent("Birthing Ritual", owner: p1) }

  def stack_library!(*names)
    cards = names.map { Card(_1, owner: p1) }
    cards.reverse_each { p1.library.add(_1) }
    cards
  end

  def bottom(count) = p1.library.cards.last(count)

  def end_step!(player = p1)
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: player))
    game.settle!
  end

  let!(:cards) do
    stack_library!("Terror Of The Peaks", "Grizzly Bears", "Llanowar Elves", "Sol Ring", "Forest", "Island", "Swamp", "Plains")
  end
  let(:terror) { cards[0] }
  let(:bears) { cards[1] }
  let(:elves) { cards[2] }

  context "when you control a creature" do
    let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "looks at the top seven and asks whether to sacrifice a creature" do
      end_step!
      choice = game.choices.first

      expect(choice).to be_a(Magic::Cards::BirthingRitual::SacrificeChoice)
      expect(choice.looked_at).to eq(cards.first(7))
      expect(choice.choices).to contain_exactly(fodder)
    end

    it "only offers your own creatures to sacrifice" do
      theirs = ResolvePermanent("Llanowar Elves", owner: p2)
      end_step!

      expect(game.choices.first.choices).to contain_exactly(fodder)
      expect(game.choices.first.choices).not_to include(theirs)
    end

    it "puts all seven on the bottom and keeps your creature if you decline to sacrifice" do
      end_step!
      game.skip_choice!

      expect(fodder.zone).to eq(game.battlefield)
      expect(bottom(7)).to contain_exactly(*cards.first(7))
      expect(p1.library.cards.first).to eq(cards[7])
      expect(game.choices).to be_empty
    end

    it "sacrifices, then puts a creature with mana value 1 plus the sacrificed creature's or less onto the battlefield" do
      end_step!
      game.resolve_choice!(target: fodder)
      choice = game.choices.first

      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(choice.choices).to contain_exactly(bears, elves)
      expect(choice.choices).not_to include(terror)

      game.resolve_choice!(target: bears)
      game.settle!

      expect(p1.creatures.map(&:card)).to include(bears)
      expect(bottom(6)).to contain_exactly(terror, elves, *cards[3..6])
      expect(p1.library.cards.first).to eq(cards[7])
    end

    it "rejects a creature card whose mana value is too high" do
      end_step!
      game.resolve_choice!(target: fodder)

      expect { game.resolve_choice!(target: terror) }.to raise_error(ArgumentError)
    end

    it "bottoms everything when you decline to put a creature onto the battlefield" do
      end_step!
      game.resolve_choice!(target: fodder)
      game.skip_choice!

      expect(p1.creatures.map(&:card)).not_to include(bears, elves)
      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(bottom(7)).to contain_exactly(*cards.first(7))
    end

    it "does nothing at the opponent's end step" do
      end_step!(p2)

      expect(game.choices).to be_empty
      expect(p1.library.cards.first).to eq(terror)
    end
  end

  context "with a cheap creature to sacrifice and a larger X" do
    let!(:token_maker) { ResolvePermanent("Llanowar Elves", owner: p1) }

    it "uses the sacrificed creature's mana value, so X is 2 for a one-drop" do
      end_step!
      game.resolve_choice!(target: token_maker)

      expect(game.choices.first.choices).to contain_exactly(bears, elves)
    end
  end

  context "when no creature card can be put onto the battlefield" do
    let!(:cards) { stack_library!("Sol Ring", "Forest", "Island", "Swamp", "Plains", "Mountain", "Terror Of The Peaks", "Forest") }
    let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "sacrifices and bottoms all seven without a further choice" do
      end_step!
      game.resolve_choice!(target: fodder)

      expect(game.choices).to be_empty
      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(bottom(7)).to contain_exactly(*cards.first(7))
    end
  end

  it "does nothing if you control no creature" do
    end_step!

    expect(game.choices).to be_empty
    expect(p1.library.cards.first).to eq(terror)
  end

  it "does not count an opponent's creature as one you control" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    end_step!

    expect(game.choices).to be_empty
  end
end
