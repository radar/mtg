# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GandalfsSanction do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def fill_graveyard(instants_and_sorceries)
    instants_and_sorceries.times do |i|
      p1.graveyard.add(Card(i.even? ? "Lightning Bolt" : "Cultivate", owner: p1))
    end
  end

  def cast_sanction(target = bears)
    p1.add_mana(blue: 1, red: 1, green: 1)
    p1.cast(card: Card("Gandalfs Sanction", owner: p1)) do
      _1.pay_mana(blue: 1, red: 1, generic: { green: 1 })
      _1.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "deals no damage with no instants or sorceries in your graveyard" do
    cast_sanction

    expect(bears.damage).to eq(0)
    expect(p2.life).to eq(20)
  end

  it "deals X damage, X being instant and sorcery cards in your graveyard, ignoring other cards" do
    fill_graveyard(1)
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    p2.graveyard.add(Card("Lightning Bolt", owner: p2))
    cast_sanction

    expect(bears.damage).to eq(1)
    expect(p2.life).to eq(20)
  end

  it "kills the creature without excess when X equals its toughness" do
    fill_graveyard(2)
    cast_sanction

    expect(bears).to be_dead
    expect(p2.life).to eq(20)
  end

  it "deals excess damage to the creature's controller instead" do
    fill_graveyard(5)
    cast_sanction

    expect(bears).to be_dead
    expect(p2.life).to eq(17)
    expect(p1.life).to eq(20)
  end

  it "counts damage already marked as part of lethal" do
    fill_graveyard(3)
    bears.take_damage(1)
    cast_sanction

    expect(bears).to be_dead
    expect(p2.life).to eq(18)
  end

  it "cannot target a hexproof creature" do
    big = ResolvePermanent("Gigantic Big Bear", owner: p2)
    p1.add_mana(blue: 1, red: 1, green: 1)

    expect do
      p1.cast(card: Card("Gandalfs Sanction", owner: p1)) do
        _1.pay_mana(blue: 1, red: 1, generic: { green: 1 })
        _1.targeting(big)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "is a sorcery, castable only on your own main phase" do
    go_to_main_phase_for!(p2)
    p1.add_mana(blue: 1, red: 1, green: 1)

    expect do
      p1.cast(card: Card("Gandalfs Sanction", owner: p1)) do
        _1.pay_mana(blue: 1, red: 1, generic: { green: 1 })
        _1.targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction)
  end
end
