# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AshlingsCommand do
  include_context "two player game"

  let(:command) { Card("Ashlings Command", owner: p1) }

  def cast_with(*modes)
    p1.hand.add(command)
    p1.add_mana(blue: 1, red: 4)
    p1.cast(card: command) do |action|
      action.pay_mana(blue: 1, red: 1, generic: { red: 3 })
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
    game.tick!
  end

  it "is an instant" do
    expect(command).to be_instant
  end

  it "draws two cards and deals 2 damage to each creature a player controls" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    hand = p1.hand.cards.count
    cast_with([described_class::Draw, p1], [described_class::Damage, p2])

    expect(p1.hand.cards.count).to eq(hand + 2)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "creates two Treasures and copies an Elemental" do
    elemental = ResolvePermanent("Shinestriker", owner: p1)
    cast_with([described_class::Treasures, p1], [described_class::CopyElemental, elemental])

    expect(p1.permanents.count { _1.name == "Treasure" }).to eq(2)
    expect(p1.creatures.count { _1.name == "Shinestriker" }).to eq(2)
  end
end
