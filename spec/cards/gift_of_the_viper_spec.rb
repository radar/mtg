# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GiftOfTheViper do
  include_context "two player game"

  let(:card) { Card("Gift Of The Viper", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_on(target)
    p1.hand.add(card)
    p1.add_mana(green: 1)
    p1.cast(card:) do |a|
      a.pay_mana(green: 1)
      a.targeting(target)
    end
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "puts a +1/+1 counter, a reach counter and a deathtouch counter on the target" do
    cast_on(bear)
    expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).size).to eq(1)
    expect(bear.counters.of_type(Magic::Counters::Reach).size).to eq(1)
    expect(bear.counters.of_type(Magic::Counters::Deathtouch).size).to eq(1)
    expect([bear.power, bear.toughness]).to eq([3, 3])
    expect(bear.has_keyword?(Magic::Keywords::REACH)).to eq(true)
    expect(bear.has_keyword?(Magic::Keywords::DEATHTOUCH)).to eq(true)
  end

  it "untaps the target" do
    bear.tap!
    cast_on(bear)
    expect(bear).not_to be_tapped
  end
end
