# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KulrathMystic do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:mystic) { ResolvePermanent("Kulrath Mystic", owner: p1) }

  def cast_big_spell(player)
    card = Card("Dream Harvest", owner: player) # mana value 7, no lasting effect on the board
    player.hand.add(card)
    player.add_mana(blue: 7)
    player.cast(card:) { _1.pay_mana(generic: { blue: 5 }, blue: 2) }
    game.settle!
    game.tick!
  end

  it "is a 2/4 Elemental Wizard" do
    expect([mystic.power, mystic.toughness]).to eq([2, 4])
  end

  it "gets +2/+0 and gains vigilance until end of turn when you cast a spell with mana value 4 or greater" do
    cast_big_spell(p1)

    expect([mystic.power, mystic.toughness]).to eq([4, 4])
    expect(mystic).to be_vigilant
  end

  it "does nothing for a cheaper spell" do
    card = Card("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
    game.tick!

    expect(mystic.power).to eq(2)
    expect(mystic).not_to be_vigilant
  end

  it "wears off at end of turn" do
    cast_big_spell(p1)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([mystic.power, mystic.vigilant?]).to eq([2, false])
  end

  it "ignores the opponent's spells" do
    go_to_main_phase_for!(p2)
    cast_big_spell(p2)

    expect(mystic.power).to eq(2)
  end
end
