# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Unbury do
  include_context "two player game"

  let(:card) { Card("Unbury", owner: p1) }
  let!(:elf) { Card("Wood Elves", owner: p1) } # Elf Scout
  let!(:other_elf) { Card("Llanowar Elves", owner: p1) } # Elf Druid
  let!(:bears) { Card("Grizzly Bears", owner: p1) } # Bear

  before do
    [elf, other_elf, bears].each { p1.graveyard.add(_1) }
    p1.hand.add(card)
  end

  def cast(mode, *targets)
    p1.add_mana(black: 2)
    p1.cast(card: card) do |action|
      action.pay_mana(black: 1, generic: { black: 1 })
      action.choose_mode(mode) { _1.targeting(*targets) }
    end
    game.stack.resolve!
  end

  it "returns target creature card from your graveyard to your hand" do
    cast(described_class::ReturnOne, bears)
    expect(bears.zone).to be_hand
    expect(elf.zone).to be_graveyard
  end

  it "can only target creature cards in your own graveyard" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    p1.graveyard.add(Card("Lightning Bolt", owner: p1))
    choices = described_class::ReturnOne.new(game: game, card: card).target_choices
    expect(choices.to_a).to contain_exactly(elf, other_elf, bears)
  end

  it "returns two creature cards that share a creature type" do
    cast(described_class::ReturnTwo, elf, other_elf)
    expect(elf.zone).to be_hand
    expect(other_elf.zone).to be_hand
    expect(bears.zone).to be_graveyard
  end

  it "can't return two cards that share no creature type" do
    expect { cast(described_class::ReturnTwo, elf, bears) }.to raise_error(Magic::Actions::Cast::InvalidTarget, /Invalid targets/)
  end

  it "can't return the same card twice" do
    expect { cast(described_class::ReturnTwo, elf, elf) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "lets you choose only one mode" do
    p1.add_mana(black: 2)
    expect do
      p1.cast(card: card) do |action|
        action.pay_mana(black: 1, generic: { black: 1 })
        action.choose_mode(described_class::ReturnOne) { _1.targeting(bears) }
        action.choose_mode(described_class::ReturnTwo) { _1.targeting(elf, other_elf) }
      end
    end.to raise_error(Magic::Actions::Cast::InvalidModes)
  end
end
