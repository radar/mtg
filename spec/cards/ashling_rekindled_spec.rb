# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AshlingRekindled do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:ashling) { ResolvePermanent("Ashling, Rekindled", owner: p1) }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  it "is a 1/3 Elemental Sorcerer" do
    expect([ashling.power, ashling.toughness]).to eq([1, 3])
    expect(ashling).to be_legendary
    expect(ashling.card).to be_double_faced
  end

  describe "entering" do
    it "may discard a card, and if it does, draws a card" do
      ashling
      game.resolve_choice! # the may choice
      hand_size = p1.hand.count
      discarded = p1.hand.cards.first
      game.resolve_choice!(card: discarded)

      expect(discarded.zone).to be_graveyard
      expect(p1.hand.count).to eq(hand_size) # discarded one, drew one
    end

    it "does nothing when you decline" do
      ashling
      hand_size = p1.hand.count
      game.skip_choice!

      expect(game.choices).to be_empty
      expect(p1.hand.count).to eq(hand_size)
    end
  end

  describe "at the beginning of your first main phase" do
    before do
      ashling
      game.skip_choice!
    end

    it "may pay {U} to transform into Ashling, Rimebound" do
      p1.add_mana(blue: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(ashling.transformed?).to be(true)
      expect(ashling.name).to eq("Ashling, Rimebound")
      expect(ashling.colors).to eq([:blue])
      expect(ashling.mana_value).to eq(2)
      expect([ashling.power, ashling.toughness]).to eq([1, 3])
    end
  end

  describe "Ashling, Rimebound" do
    before do
      ashling
      game.skip_choice!
      ashling.transform!
      game.settle!
    end

    it "adds two mana of one color when it transforms, spendable only on spells with mana value 4 or more" do
      game.resolve_choice!(color: :red)

      expect(p1.restricted_mana.map(&:color)).to eq(%i[red red])
    end

    it "adds the mana again at the beginning of your first main phase" do
      game.resolve_choice!(color: :red)
      first_main_phase!
      game.resolve_choice!(color: :green)

      expect(p1.restricted_mana.map(&:color).tally).to eq(red: 2, green: 2)
    end

    it "can pay for a spell with mana value 4 or more with that mana" do
      game.resolve_choice!(color: :green)
      p1.add_mana(green: 2)
      spell = Card("Sunderflock", owner: p1) # mana value 9, reduced below by nothing here
      restriction = p1.restricted_mana.first.restriction

      expect(restriction.permits?(spell)).to be(true)
    end

    it "cannot pay for a cheaper spell, or for an ability" do
      game.resolve_choice!(color: :green)
      restriction = p1.restricted_mana.first.restriction

      expect(restriction.permits?(Card("Grizzly Bears", owner: p1))).to be(false)
      expect(restriction.permits?(ashling)).to be(false)
    end

    it "may pay {R} to transform back" do
      game.resolve_choice!(color: :red)
      p1.add_mana(red: 1)
      first_main_phase!
      # A pending choice holds up the other trigger; answer each choice as it comes.
      until game.choices.empty?
        case game.choices.first
        when Magic::Choice::PayToTransform then game.resolve_choice!(payment: nil)
        when Magic::Choice::Color then game.resolve_choice!(color: :red)
        else game.skip_choice! # transforming back loots again: decline
        end
        game.settle!
      end

      expect(ashling.transformed?).to be(false)
      expect(ashling.name).to eq("Ashling, Rekindled")
    end
  end
end
