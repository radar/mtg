# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BreOfClanStoutarm do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bre) { ResolvePermanent("Bre Of Clan Stoutarm", owner: p1) }

  def end_step!
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))
    game.settle!
  end

  def library_top(*cards)
    p1.library.to_a.each { p1.library.remove(_1) }
    cards.reverse.each { p1.library.add(_1) }
  end

  it "is a 4/4 legendary Giant Warrior" do
    expect([bre.power, bre.toughness]).to eq([4, 4])
    expect(bre).to be_legendary
  end

  describe "{1}{W}, {T}: another target creature you control gains flying and lifelink" do
    it "grants both until end of turn" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(white: 2)
      p1.activate_ability(ability: bre.activated_abilities.first) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
      game.stack.resolve!
      game.tick!

      expect(bears).to be_flying
      expect(bears).to be_lifelink
      expect(bre).to be_tapped
    end

    it "can't target itself" do
      ability = bre.activated_abilities.first

      expect(ability.target_choices).not_to include(bre)
    end
  end

  describe "at the beginning of your end step" do
    it "does nothing if you didn't gain life this turn" do
      top = p1.library.first
      end_step!

      expect(top.zone).to be_library
    end

    it "exiles until a nonland card, then offers to cast it free if its mana value is at most the life gained" do
      forest = Card("Forest", owner: p1)
      bears = Card("Grizzly Bears", owner: p1) # mana value 2
      library_top(forest, bears)
      p1.gain_life(3)
      end_step!

      expect(forest.zone).to be_exile
      choice = game.choices.last
      expect(choice).to be_a(described_class::CastOrHandChoice)
      game.resolve_choice!
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "puts the card into your hand when you decline to cast it" do
      bears = Card("Grizzly Bears", owner: p1)
      library_top(bears)
      p1.gain_life(2)
      end_step!
      game.skip_choice!

      expect(bears.zone).to be_hand
    end

    it "puts the card into your hand when its mana value is more than the life gained" do
      courser = Card("Courser Of Kruphix", owner: p1) # mana value 3
      library_top(courser)
      p1.gain_life(2)
      end_step!

      expect(courser.zone).to be_hand
      expect(game.choices).to be_empty
    end

    it "does nothing at the opponent's end step" do
      p1.gain_life(3)
      top = p1.library.first
      game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p2))
      game.settle!

      expect(top.zone).to be_library
    end
  end
end
