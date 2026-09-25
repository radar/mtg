# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwilightDiviner do
  include_context "two player game"

  let!(:diviner) do
    ResolvePermanent("Twilight Diviner", owner: p1).tap { game.resolve_choice!(top: p1.library.first(2)) if game.choices.any? }
  end

  def tokens_named(name) = battlefield.creatures.select { |c| c.token? && c.name == name }

  def battlefield = game.battlefield

  it "is a 3/3 Elf Cleric" do
    expect(diviner.power).to eq(3)
    expect(diviner.toughness).to eq(3)
    expect(diviner.type?("Elf")).to eq(true)
    expect(diviner.type?("Cleric")).to eq(true)
  end

  it "surveils 2 when it enters" do
    go_to_main_phase!
    p1.add_mana(black: 3)
    card = Card("Twilight Diviner")
    p1.hand.add(card)
    p1.cast(card: card) { _1.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(2)
  end

  context "when another creature enters from a graveyard" do
    def reanimate(name)
      card = Card(name)
      p1.graveyard.add(card)
      Magic::Permanent.resolve(game: game, owner: p1, card: card)
      game.settle!
    end

    it "creates a token copy of it" do
      reanimate("Grizzly Bears")
      expect(tokens_named("Grizzly Bears").count).to eq(1)
    end

    it "triggers only once each turn" do
      reanimate("Grizzly Bears")
      reanimate("Llanowar Elves")
      expect(tokens_named("Grizzly Bears").count).to eq(1)
      expect(tokens_named("Llanowar Elves").count).to eq(0)
    end

    it "does not trigger for an opponent's creature" do
      card = Card("Grizzly Bears")
      p2.graveyard.add(card)
      Magic::Permanent.resolve(game: game, owner: p2, card: card)
      game.settle!
      expect(tokens_named("Grizzly Bears")).to be_empty
    end
  end

  it "does not trigger for a creature that enters from elsewhere" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    expect(tokens_named("Grizzly Bears")).to be_empty
  end
end
