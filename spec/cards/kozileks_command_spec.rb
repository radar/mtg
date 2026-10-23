# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KozileksCommand do
  include_context "two player game"

  let(:card) { Card("Kozileks Command", owner: p1) }

  def cast(x:, &modes)
    p1.hand.add(card)
    p1.add_mana(colorless: x + 2)
    p1.cast(card:, value_for_x: x) do |action|
      modes.call(action)
      action.pay_mana(x: { colorless: x }, colorless: 2)
    end
    game.stack.resolve!
    game.settle!
  end

  def spawns(player) = player.creatures.select { _1.name == "Eldrazi Spawn" }

  it "creates X Eldrazi Spawn for the target player" do
    cast(x: 3) do |action|
      action.choose_mode(described_class::Spawn) { _1.targeting(p2) }
      action.choose_mode(described_class::ScryThenDraw) { _1.targeting(p1) }
    end
    game.skip_choice! if game.choices.any?

    expect(spawns(p2).count).to eq(3)
  end

  it "scries X then draws a card for the target player" do
    hand = p2.hand.count
    cast(x: 2) do |action|
      action.choose_mode(described_class::ScryThenDraw) { _1.targeting(p2) }
      action.choose_mode(described_class::Spawn) { _1.targeting(p1) }
    end
    game.skip_choice!

    expect(p2.hand.count).to eq(hand + 1)
  end

  it "exiles a creature with mana value X or less" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast(x: 2) do |action|
      action.choose_mode(described_class::ExileCreature) { _1.targeting(bears) }
      action.choose_mode(described_class::Spawn) { _1.targeting(p1) }
    end

    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "cannot target a creature with mana value above X" do
    dreadmaw = ResolvePermanent("Colossal Dreadmaw", owner: p2)
    p1.hand.add(card)
    p1.add_mana(colorless: 3)

    expect do
      p1.cast(card:, value_for_x: 1) do |action|
        action.choose_mode(described_class::ExileCreature) { _1.targeting(dreadmaw) }
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "exiles up to X cards from graveyards" do
    mine, theirs, extra = [p1.hand.cards.first, p2.hand.cards.first, p2.hand.cards.last]
    [mine, theirs, extra].each(&:move_to_graveyard!)
    cast(x: 2) do |action|
      action.choose_mode(described_class::ExileFromGraveyards) { _1.targeting(mine, theirs) }
      action.choose_mode(described_class::Spawn) { _1.targeting(p1) }
    end

    exiled = game.exile.cards
    expect(exiled).to include(mine, theirs)
    expect(exiled).not_to include(extra)
  end

  it "cannot target more than X cards in graveyards" do
    cards = [p1.hand.cards.first, p2.hand.cards.first, p2.hand.cards.last]
    cards.each(&:move_to_graveyard!)
    p1.hand.add(card)
    p1.add_mana(colorless: 4)

    expect do
      p1.cast(card:, value_for_x: 2) do |action|
        action.choose_mode(described_class::ExileFromGraveyards) { _1.targeting(*cards) }
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "has the target player, not the caster, scry X" do
    cast(x: 2) do |action|
      action.choose_mode(described_class::ScryThenDraw) { _1.targeting(p2) }
      action.choose_mode(described_class::Spawn) { _1.targeting(p1) }
    end

    scry = game.choices.first
    expect(scry).to be_a(described_class::ScryChoice)
    expect(scry.chooser).to eq(p2)
    expect(scry.amount).to eq(2)
  end
end
