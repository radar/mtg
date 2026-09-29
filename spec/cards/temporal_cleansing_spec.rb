# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TemporalCleansing do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Temporal Cleansing", owner: p1) }

  def cast_on(target)
    p1.hand.add(card)
    p1.add_mana(blue: 4)
    p1.cast(card:) { _1.pay_mana(generic: { blue: 3 }, blue: 1).targeting(target) }
    game.stack.resolve!
  end

  it "has convoke" do
    expect(card.convoke?).to be(true)
  end

  it "lets the owner put the permanent second from the top of their library" do
    stone = ResolvePermanent("Mind Stone", owner: p2)
    cast_on(stone)
    game.resolve_choice!(position: :second)

    expect(game.battlefield.permanents).not_to include(stone)
    expect(p2.library.to_a[1]).to eq(stone.card)
  end

  it "lets the owner put it on the bottom" do
    stone = ResolvePermanent("Mind Stone", owner: p2)
    cast_on(stone)
    game.resolve_choice!(position: :bottom)

    expect(p2.library.to_a.last).to eq(stone.card)
  end

  it "can't target a land" do
    forest = ResolvePermanent("Forest", owner: p2)

    expect(card.target_choices).not_to include(forest)
  end

  it "targets your own permanent too, and it goes to your library" do
    mine = ResolvePermanent("Mind Stone", owner: p1)
    cast_on(mine)
    game.resolve_choice!(position: :bottom)

    expect(p1.library.to_a.last).to eq(mine.card)
  end
end
