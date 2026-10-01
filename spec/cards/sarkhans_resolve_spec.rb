# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SarkhansResolve do
  include_context "two player game"

  let(:resolve) { Card("Sarkhan's Resolve", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.hand.add(resolve)
    p1.add_mana(green: 2)
  end

  def cast_mode(mode, target)
    p1.cast(card: resolve) do |action|
      action.pay_mana(green: 1, generic: { green: 1 })
      action.choose_mode(mode) { _1.targeting(target) }
    end
    game.stack.resolve!
    game.tick!
  end

  it "gives target creature +3/+3 until end of turn" do
    cast_mode(described_class::Mode1, bears)
    expect([bears.power, bears.toughness]).to eq([5, 5])

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  it "destroys target creature with flying" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p2)
    cast_mode(described_class::Mode2, angel)
    expect(p2.graveyard.cards.map(&:name)).to include("Baneslayer Angel")
  end

  it "cannot destroy a creature without flying" do
    expect { cast_mode(described_class::Mode2, bears) }.to raise_error(StandardError)
    expect(game.battlefield.creatures).to include(bears)
  end
end
