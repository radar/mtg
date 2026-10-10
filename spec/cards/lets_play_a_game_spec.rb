# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LetsPlayAGame do
  include_context "two player game"

  let(:card) { Card("Let's Play A Game", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
  end

  def fill_graveyard!
    %w[Grizzly\ Bears Island Lightning\ Bolt Cultivate].each { p1.graveyard.add(Card(_1, owner: p1)) }
  end

  def cast_with(*modes)
    p1.add_mana(black: 4)
    p1.cast(card: card) do |action|
      action.pay_mana(black: 1, generic: { black: 3 })
      modes.each { |mode| action.choose_mode(mode) }
    end
    game.stack.resolve!
    game.settle!
  end

  it "gives opponents' creatures -1/-1 until end of turn" do
    cast_with(described_class::ShrinkCreatures)

    expect([bears.power, bears.toughness]).to eq([1, 1])
    expect([mine.power, mine.toughness]).to eq([2, 2])
  end

  it "makes each opponent discard two cards" do
    before = p2.hand.count
    cast_with(described_class::DiscardTwo)

    expect(game.choices.last.player).to eq(p2)
    game.resolve_choice!(cards: p2.hand.cards.first(2))
    expect(p2.hand.count).to eq(before - 2)
  end

  it "drains each opponent for 3" do
    cast_with(described_class::Drain)

    expect(p2.life).to eq(17)
    expect(p1.life).to eq(23)
  end

  it "allows only one mode without delirium" do
    expect do
      cast_with(described_class::Drain, described_class::ShrinkCreatures)
    end.to raise_error(Magic::Actions::Cast::InvalidModes)
  end

  it "allows several modes with delirium" do
    fill_graveyard!
    cast_with(described_class::Drain, described_class::ShrinkCreatures)

    expect(p2.life).to eq(17)
    expect(p1.life).to eq(23)
    expect(bears.toughness).to eq(1)
  end
end
