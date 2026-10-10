# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfImmobility do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def stuns(permanent) = permanent.counters.of_type(Magic::Counters["stun"]).count

  def cast_fear
    card = Card("Fear Of Immobility", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 5)
    p1.cast(card: card) { |a| a.pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/4 enchantment creature" do
    fear = ResolvePermanent("Fear Of Immobility", owner: p1)

    expect(fear).to be_creature
    expect(fear.type?("Enchantment")).to be(true)
    expect([fear.power, fear.toughness]).to eq([4, 4])
  end

  it "taps an opponent's creature and stuns it" do
    cast_fear
    game.resolve_choice!(target: theirs)
    game.settle!

    expect(theirs).to be_tapped
    expect(stuns(theirs)).to eq(1)
  end

  it "taps its controller's creature without stunning it" do
    cast_fear
    game.resolve_choice!(target: mine)
    game.settle!

    expect(mine).to be_tapped
    expect(stuns(mine)).to eq(0)
  end

  it "can choose no target" do
    cast_fear
    game.skip_choice!

    expect(theirs).not_to be_tapped
  end
end
