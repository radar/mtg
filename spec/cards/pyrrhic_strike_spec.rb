# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PyrrhicStrike do
  include_context "two player game"

  let(:card) { Card("Pyrrhic Strike", owner: p1) }
  let!(:stone) { ResolvePermanent("Mind Stone", owner: p2) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p2) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:own_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
  end

  def cast(blight: nil, modes: [])
    p1.add_mana(white: 3)
    p1.cast(card: card) do |action|
      action.pay_mana(white: 1, generic: { white: 2 })
      action.pay_kicker(blight) if blight
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
  end

  it "destroys target artifact or enchantment" do
    cast(modes: [[described_class::DestroyArtifactOrEnchantment, stone]])
    expect(stone.zone).to be_nil
  end

  it "destroys target creature with mana value 3 or greater" do
    cast(modes: [[described_class::DestroyCreature, angel]])
    expect(angel.zone).to be_nil
  end

  it "can't target a creature with mana value less than 3" do
    expect(described_class::DestroyCreature.new(game: game, card: card).target_choices).to contain_exactly(angel)
  end

  it "lets you choose only one mode without the additional cost" do
    expect do
      cast(modes: [[described_class::DestroyArtifactOrEnchantment, stone], [described_class::DestroyCreature, angel]])
    end.to raise_error(Magic::Actions::Cast::InvalidModes, /at most 1/)
  end

  it "needs a mode chosen" do
    expect { cast }.to raise_error(Magic::Actions::Cast::InvalidModes)
  end

  it "chooses both if you blight 2 as an additional cost" do
    cast(blight: own_bears, modes: [[described_class::DestroyArtifactOrEnchantment, stone], [described_class::DestroyCreature, angel]])

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
    expect(stone.zone).to be_nil
    expect(angel.zone).to be_nil
  end

  it "forgets the additional cost after resolving" do
    cast(blight: own_bears, modes: [[described_class::DestroyArtifactOrEnchantment, stone], [described_class::DestroyCreature, angel]])
    expect(card.kicker_cost.paid?).to eq(false)
    expect(card.modes_to_choose).to eq(1)
  end
end
