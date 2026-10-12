# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanctumOfShatteredHeights do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:sanctum) { ResolvePermanent("Sanctum Of Shattered Heights", owner: p1) }
  let!(:target) { ResolvePermanent("Baneslayer Angel", owner: p2) }

  def activate(discard)
    p1.hand.add(discard)
    p1.add_mana(red: 1)
    p1.activate_ability(ability: sanctum.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 1 })
      a.pay_discard(discard)
      a.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary Shrine" do
    expect(sanctum.type?("Shrine")).to eq(true)
  end

  it "deals damage equal to the Shrines you control, discarding a land" do
    activate(Card("Forest", owner: p1))

    expect(target.damage).to eq(1)
  end

  it "counts every Shrine you control, discarding a Shrine" do
    ResolvePermanent("Sanctum Of Tranquil Light", owner: p1)
    activate(Card("Sanctum Of Fruitful Harvest", owner: p1))

    expect(target.damage).to eq(2)
  end

  it "can't discard a card that is neither a land nor a Shrine" do
    p1.add_mana(red: 1)
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)

    expect do
      p1.activate_ability(ability: sanctum.activated_abilities.first) do |a|
        a.pay_mana(generic: { red: 1 })
        a.pay_discard(bears)
      end
    end.to raise_error(StandardError)
  end
end
