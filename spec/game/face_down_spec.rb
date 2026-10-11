# frozen_string_literal: true

require "spec_helper"

RSpec.describe "face-down permanents (manifest dread)" do
  include_context "two player game"

  let!(:source) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def put_on_top(*names)
    names.reverse_each { |name| p1.library.add(Card(name, owner: p1)) }
    p1.library.first(names.size)
  end

  def empty_library!(player = p1)
    player.library.cards.to_a.dup.each { player.library.remove(_1) }
  end

  def manifest_dread!(player: p1)
    Magic::Choice::ManifestDread.perform(actor: source, player: player)
    game.settle!
  end

  def face_down = p1.permanents.select(&:face_down?)

  describe "manifest dread" do
    it "asks which of the top two cards to put onto the battlefield face down, and mills the other" do
      shroudstomper, island = put_on_top("Shroudstomper", "Island")
      manifest_dread!

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::ManifestDread)
      expect(choice.choices).to eq([shroudstomper, island])
      game.resolve_choice!(target: shroudstomper)

      expect(face_down.map(&:card)).to eq([shroudstomper])
      expect(island.zone).to be_graveyard
    end

    it "manifests the only card left in the library without asking" do
      empty_library!
      only = put_on_top("Shroudstomper").first
      manifest_dread!

      expect(game.choices).to be_empty
      expect(face_down.map(&:card)).to eq([only])
    end

    it "does nothing with an empty library" do
      empty_library!
      manifest_dread!

      expect(game.choices).to be_empty
      expect(face_down).to be_empty
    end

    it "lets another player manifest dread (\"its controller manifests dread\")" do
      p2_top = p2.library.first(2)
      manifest_dread!(player: p2)
      game.resolve_choice!(target: p2_top.first)

      expect(p2.permanents.select(&:face_down?).map(&:card)).to eq([p2_top.first])
    end
  end

  describe "a face-down permanent" do
    let!(:manifested) do
      shroudstomper, = put_on_top("Shroudstomper", "Island")
      manifest_dread!
      game.resolve_choice!(target: shroudstomper)
      game.settle!
      face_down.first
    end

    it "is a colourless 2/2 creature with no name, abilities or subtypes" do
      expect(manifested.name).to eq("Face-down creature")
      expect([manifested.power, manifested.toughness]).to eq([2, 2])
      expect(manifested.types).to eq([Magic::Types::Creature])
      expect(manifested.colors).to be_empty
      expect(manifested.mana_value).to eq(0)
      expect(manifested.keywords).to be_empty
      expect(manifested).not_to have_keyword(:deathtouch)
    end

    it "does not trigger the card's enters-the-battlefield ability" do
      expect(p2.life).to eq(20)
      expect(p1.life).to eq(20)
    end

    it "enters untapped even when the card enters tapped" do
      empty_library!
      put_on_top("Bojuka Bog")
      manifest_dread!

      expect(face_down.first).not_to be_tapped
    end

    it "is a creature with summoning sickness like any permanent entering now" do
      expect(manifested.summoning_sick?).to be(true)
    end

    it "remembers that it entered face down after it is turned face up" do
      expect(manifested.entered_face_down?).to be(true)
      p1.add_mana(black: 5, white: 2)
      p1.turn_face_up(permanent: manifested) { |a| a.pay_mana(generic: { black: 3 }, black: 2, white: 2) }

      expect(manifested.entered_face_down?).to be(true)
    end

    it "goes to the graveyard as the real card when it dies" do
      manifested.destroy!
      game.settle!

      expect(p1.graveyard.cards.map(&:name)).to include("Shroudstomper")
      expect(manifested.zone).to be_nil
    end
  end

  describe "turning a creature card face up" do
    let(:bears_card) { put_on_top("Grizzly Bears", "Island").first }
    let!(:manifested) do
      card = bears_card
      manifest_dread!
      game.resolve_choice!(target: card)
      game.settle!
      face_down.first
    end

    it "costs the card's mana cost, and the permanent becomes the real creature" do
      p1.add_mana(green: 2)
      p1.turn_face_up(permanent: manifested) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(manifested).not_to be_face_down
      expect(manifested.name).to eq("Grizzly Bears")
      expect(manifested.colors).to eq([:green])
      expect(manifested.type?("Bear")).to be(true)
      expect(game.current_turn.events.map(&:class)).to include(Magic::Events::TurnedFaceUp)
    end

    it "is not an enters-the-battlefield event" do
      before_count = game.current_turn.events.count { _1.is_a?(Magic::Events::EnteredTheBattlefield) }
      p1.add_mana(green: 2)
      p1.turn_face_up(permanent: manifested) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.current_turn.events.count { _1.is_a?(Magic::Events::EnteredTheBattlefield) }).to eq(before_count)
    end

    it "keeps its counters, damage and tapped state" do
      manifested.add_counter("+1/+1")
      manifested.tap!
      p1.add_mana(green: 2)
      p1.turn_face_up(permanent: manifested) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(manifested).to be_tapped
      expect(manifested.power).to eq(3)
    end

    it "can't be done for the opponent's permanent or without paying" do
      action = Magic::Actions::TurnFaceUp.new(game: game, player: p2, permanent: manifested)
      expect(action.illegal_reason).to match(/does not control/)

      expect { p1.turn_face_up(permanent: manifested) }.to raise_error(Magic::Costs::Mana::OutstandingBalance)
      expect(manifested).to be_face_down
    end

    it "is offered as a legal action when affordable" do
      expect(game.legal_actions(p1).grep(Magic::Actions::TurnFaceUp)).to be_empty

      p1.add_mana(green: 2)
      expect(game.legal_actions(p1).grep(Magic::Actions::TurnFaceUp).map(&:permanent)).to eq([manifested])
    end
  end

  describe "a manifested card that is not a creature card" do
    it "is a 2/2 creature that can't be turned face up" do
      island = put_on_top("Island", "Forest").first
      manifest_dread!
      game.resolve_choice!(target: island)
      manifested = face_down.first

      expect([manifested.power, manifested.toughness]).to eq([2, 2])
      action = Magic::Actions::TurnFaceUp.new(game: game, player: p1, permanent: manifested)
      expect(action.illegal_reason).to match(/not a creature card/)
      expect(game.legal_actions(p1).grep(Magic::Actions::TurnFaceUp)).to be_empty
    end
  end
end
