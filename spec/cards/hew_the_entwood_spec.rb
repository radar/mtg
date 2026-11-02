# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HewTheEntwood do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:forest1) { ResolvePermanent("Forest", owner: p1) }
  let!(:forest2) { ResolvePermanent("Forest", owner: p1) }
  let!(:forest3) { ResolvePermanent("Forest", owner: p1) }
  let(:sol_ring) { Card("Sol Ring", owner: p1) }
  let(:island) { Card("Island", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:mountain) { Card("Mountain", owner: p1) }

  def stack_library(*cards)
    cards.reverse_each { p1.library.add(_1) }
  end

  def cast_hew
    hew = Card("Hew The Entwood", owner: p1)
    p1.hand.add(hew)
    p1.add_mana(red: 5)
    action = cast_action(card: hew, player: p1)
    action.pay_mana(generic: { red: 3 }, red: 2)
    game.take_action(action)
    game.settle!
    game.stack.resolve!
    game.tick!
  end

  def choice = game.choices.first

  it "is a sorcery costing {3}{R}{R}" do
    expect(Card("Hew The Entwood").type?("Sorcery")).to eq(true)
  end

  it "can only be cast at sorcery speed" do
    go_to_main_phase_for!(p2)
    hew = Card("Hew The Entwood", owner: p1)
    p1.hand.add(hew)
    p1.add_mana(red: 5)
    action = cast_action(card: hew, player: p1)
    action.pay_mana(generic: { red: 3 }, red: 2)
    expect { game.take_action(action) }.to raise_error(Magic::IllegalAction)
  end

  context "when it resolves" do
    before { stack_library(sol_ring, island, bears, mountain) }

    it "asks for lands to sacrifice, offering only your lands" do
      ResolvePermanent("Forest", owner: p2)
      cast_hew
      expect(choice).to be_a(described_class::SacrificeLands)
      expect(choice.choices).to contain_exactly(forest1, forest2, forest3)
    end

    it "sacrificing no lands reveals nothing" do
      cast_hew
      game.skip_choice!
      expect(game.choices).to be_empty
      expect(p1.library.first(4).map(&:name)).to eq(["Sol Ring", "Island", "Grizzly Bears", "Mountain"])
      expect(p1.permanents.select { _1.type?("Land") }.count).to eq(3)
    end

    it "sacrifices the chosen lands and reveals that many cards" do
      cast_hew
      game.resolve_choice!(sacrifices: [forest1, forest2])
      expect(p1.permanents.select { _1.type?("Land") }).to eq([forest3])
      expect(p1.graveyard.cards.map(&:name)).to include("Forest", "Hew the Entwood")
      expect(choice).to be_a(described_class::PutRevealed)
      expect(choice.revealed.map(&:name)).to eq(["Sol Ring", "Island"])
    end

    it "puts chosen artifacts and lands onto the battlefield, lands tapped" do
      cast_hew
      game.resolve_choice!(sacrifices: [forest1, forest2])
      game.resolve_choice!(choices: [sol_ring, island])
      game.tick!
      sol = p1.permanents.find { _1.name == "Sol Ring" }
      isl = p1.permanents.find { _1.name == "Island" }
      expect(sol).not_to be_nil
      expect(sol).not_to be_tapped
      expect(isl).to be_tapped
    end

    it "offers only artifact and land cards" do
      cast_hew
      game.resolve_choice!(sacrifices: [forest1, forest2, forest3])
      expect(choice.choices).to contain_exactly(sol_ring, island)
      expect(choice.revealed.map(&:name)).to eq(["Sol Ring", "Island", "Grizzly Bears"])
    end

    it "rejects a nonartifact nonland card" do
      cast_hew
      game.resolve_choice!(sacrifices: [forest1, forest2, forest3])
      expect { game.resolve_choice!(choices: [bears]) }.to raise_error(ArgumentError)
    end

    it "puts unchosen revealed cards on the bottom of the library" do
      cast_hew
      game.resolve_choice!(sacrifices: [forest1, forest2, forest3])
      game.resolve_choice!(choices: [island])
      game.tick!
      expect(p1.library.first.name).to eq("Mountain")
      expect(p1.library.cards.last(2).map(&:name)).to contain_exactly("Sol Ring", "Grizzly Bears")
      expect(p1.permanents.map(&:name)).to include("Island")
    end

    it "choosing none puts all revealed cards on the bottom" do
      cast_hew
      game.resolve_choice!(sacrifices: [forest1, forest2])
      game.resolve_choice!(choices: [])
      expect(p1.library.first.name).to eq("Grizzly Bears")
      expect(p1.library.cards.last(2).map(&:name)).to contain_exactly("Sol Ring", "Island")
    end

    it "rejects a sacrifice of a land the opponent controls" do
      theirs = ResolvePermanent("Forest", owner: p2)
      cast_hew
      expect { game.resolve_choice!(sacrifices: [theirs]) }.to raise_error(ArgumentError)
    end
  end
end
