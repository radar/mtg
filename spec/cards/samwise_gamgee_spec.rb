# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SamwiseGamgee do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:samwise) { ResolvePermanent("Samwise Gamgee", owner: p1) }

  def foods(player) = player.permanents.select { _1.type?("Food") }

  it "is a 2/2" do
    expect([samwise.power, samwise.toughness]).to eq([2, 2])
  end

  context "Food trigger" do
    it "creates a Food when another nontoken creature enters under your control" do
      ResolvePermanent("Grizzly Bears", owner: p1)

      expect(foods(p1).count).to eq(1)
    end

    it "does not trigger for a token creature" do
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      p1.trigger_effect(:create_token, token_class: Magic::Cards::GhostlyDancers::SpiritToken)
      game.settle!

      expect(foods(p1).count).to eq(1)
    end

    it "does not trigger for a noncreature permanent" do
      ResolvePermanent("Springleaf Drum", owner: p1)

      expect(foods(p1).count).to eq(0)
    end

    it "does not trigger for an opponent's creature" do
      ResolvePermanent("Grizzly Bears", owner: p2)

      expect(foods(p1).count).to eq(0)
    end

    it "does not trigger for Samwise himself" do
      game.settle!

      expect(foods(p1).count).to eq(0)
    end
  end

  context "Sacrifice three Foods" do
    def ability = samwise.activated_abilities.first

    def make_foods(count)
      count.times.map { Magic::Tokens::Food.new(game: game, owner: p1).resolve! }
    end

    def graveyard_card(name)
      card = Card(name, owner: p1)
      p1.graveyard.add(card)
      card
    end

    def activate(foods, target)
      p1.activate_ability(ability: ability) do |a|
        a.pay_sacrifice(foods)
        a.targeting(target)
      end
      game.stack.resolve!
      game.tick!
    end

    it "returns a legendary card from your graveyard to your hand" do
      elanor = graveyard_card("Elanor Gardner")
      activate(make_foods(3), elanor)

      expect(elanor.zone).to eq(p1.hand)
      expect(foods(p1).count).to eq(0)
    end

    it "returns an artifact card" do
      drum = graveyard_card("Springleaf Drum")
      activate(make_foods(3), drum)

      expect(drum.zone).to eq(p1.hand)
    end

    it "returns a Saga card" do
      saga = graveyard_card("Binding The Old Gods")
      activate(make_foods(3), saga)

      expect(saga.zone).to eq(p1.hand)
    end

    it "offers only historic cards as targets" do
      graveyard_card("Serra Angel")
      elanor = graveyard_card("Elanor Gardner")

      expect(ability.target_choices).to eq([elanor])
    end

    it "does not offer a historic card in an opponent's graveyard as a target" do
      elanor = graveyard_card("Elanor Gardner")
      theirs = Card("Springleaf Drum", owner: p2)
      p2.graveyard.add(theirs)

      expect(ability.target_choices).to eq([elanor])
      expect(ability.target_choices).not_to include(theirs)
    end

    it "cannot be paid with Foods you do not control" do
      make_foods(2)
      Magic::Tokens::Food.new(game: game, owner: p2).resolve!

      expect(foods(p1).count).to eq(2)
      expect(foods(p2).count).to eq(1)
      expect(ability.costs.first.can_pay?(p1)).to be(false)
    end

    it "cannot be paid with fewer than three Foods" do
      make_foods(2)

      expect(ability.costs.first.can_pay?(p1)).to be(false)
    end
  end
end
