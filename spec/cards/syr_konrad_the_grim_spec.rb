# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SyrKonradTheGrim do
  include_context "two player game"

  let!(:konrad) { ResolvePermanent("Syr Konrad The Grim", owner: p1) }

  it "pings each opponent when another creature dies" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "doesn't ping when it dies itself" do
    konrad.destroy!
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "pings when a creature card is milled into a graveyard" do
    p2.library.add(Card("Grizzly Bears", owner: p2))
    p2.mill(1)
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "doesn't ping for a milled noncreature card" do
    p2.library.add(Card("Forest", owner: p2))
    p2.mill(1)
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "pings when a creature card leaves your graveyard" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bears)
    bears.exile!
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "doesn't ping when a creature card leaves the opponent's graveyard" do
    bears = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(bears)
    bears.exile!
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "makes each player mill a card for {1}{B}" do
    p1_lib = p1.library.count
    p2_lib = p2.library.count
    p1.add_mana(black: 2)
    p1.activate_ability(ability: konrad.activated_abilities.first) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!

    expect(p1.library.count).to eq(p1_lib - 1)
    expect(p2.library.count).to eq(p2_lib - 1)
  end
end
