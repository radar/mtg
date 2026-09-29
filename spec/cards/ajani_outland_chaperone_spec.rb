# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AjaniOutlandChaperone do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:ajani) { ResolvePermanent("Ajani, Outland Chaperone", owner: p1) }

  def activate(index, target: nil)
    p1.activate_loyalty_ability(ability: ajani.loyalty_abilities[index]) { |action| action.targeting(target) if target }
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary Ajani planeswalker with 3 loyalty" do
    expect(ajani.loyalty).to eq(3)
    expect(ajani).to be_planeswalker
  end

  it "+1: creates a 1/1 green and white Kithkin creature token" do
    activate(0)
    kithkin = p1.creatures.find { _1.name == "Kithkin" }

    expect(ajani.loyalty).to eq(4)
    expect([kithkin.power, kithkin.toughness]).to eq([1, 1])
    expect(kithkin.colors).to contain_exactly(:green, :white)
  end

  it "−2: deals 4 damage to target tapped creature" do
    tapped = ResolvePermanent("Courser Of Kruphix", owner: p2)
    tapped.tap!
    activate(1, target: tapped)

    expect(ajani.loyalty).to eq(1)
    expect(tapped.card.zone).to be_graveyard
  end

  it "−2 can't target an untapped creature" do
    untapped = ResolvePermanent("Courser Of Kruphix", owner: p2)

    expect(ajani.loyalty_abilities[1].target_choices).not_to include(untapped)
  end

  describe "−8: look at the top X cards, put any number of cheap nonland permanents onto the battlefield" do
    before { ajani.change_loyalty!(5) }

    def stack_library(*cards)
      p1.library.to_a.each { p1.library.remove(_1) }
      cards.reverse.each { p1.library.add(_1) }
    end

    it "offers the nonland permanent cards with mana value 3 or less among the top X (X = your life)" do
      bears = Card("Grizzly Bears", owner: p1)
      forest = Card("Forest", owner: p1)
      courser = Card("Courser Of Kruphix", owner: p1) # mana value 3
      big = Card("Sunderflock", owner: p1)
      bolt = Card("Lightning Bolt", owner: p1)
      stack_library(forest, bears, big, bolt, courser)
      activate(2)
      choice = game.choices.last

      expect(choice.choices).to contain_exactly(bears, courser)
    end

    it "puts the chosen cards onto the battlefield, then shuffles" do
      bears = Card("Grizzly Bears", owner: p1)
      stack_library(bears)
      activate(2)
      game.resolve_choice!(targets: [bears])

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "may put none" do
      bears = Card("Grizzly Bears", owner: p1)
      stack_library(bears)
      activate(2)
      game.resolve_choice!(targets: [])

      expect(bears.zone).to be_library
    end

    it "only looks at as many cards as your life total" do
      p1.lose_life(17)
      deep = Card("Grizzly Bears", owner: p1)
      filler = 5.times.map { Card("Forest", owner: p1) }
      stack_library(*filler, deep)
      activate(2)

      expect(game.choices.last.choices).to be_empty
    end

    it "can't take a card that isn't offered" do
      big = Card("Sunderflock", owner: p1)
      stack_library(big)
      activate(2)

      expect { game.resolve_choice!(targets: [big]) }.to raise_error(ArgumentError)
    end
  end
end
