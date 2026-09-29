# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FigureOfFable do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:figure) { ResolvePermanent("Figure Of Fable", owner: p1) }

  def activate(index, mana)
    p1.add_mana(mana)
    p1.activate_ability(ability: figure.activated_abilities[index]) { _1.pay_mana(mana) }
    game.stack.resolve!
    game.tick!
  end

  def become_scout = activate(0, { green: 1 })
  it "is a 1/1 Kithkin" do
    expect([figure.power, figure.toughness]).to eq([1, 1])
    expect(figure.type?("Kithkin")).to be(true)
  end

  it "{G/W}: becomes a Kithkin Scout with base power and toughness 2/3" do
    become_scout

    expect([figure.power, figure.toughness]).to eq([2, 3])
    expect(figure.type?("Scout")).to be(true)
    expect(figure.type?("Kithkin")).to be(true)
  end

  it "{1}{G/W}{G/W}: only a Scout becomes a Kithkin Soldier 4/5" do
    p1.add_mana(green: 3)
    p1.activate_ability(ability: figure.activated_abilities[1]) { _1.pay_mana(generic: { green: 1 }, green: 2) }
    game.stack.resolve!
    game.tick!
    expect([figure.power, figure.toughness]).to eq([1, 1]) # not a Scout yet

    become_scout
    p1.add_mana(green: 3)
    p1.activate_ability(ability: figure.activated_abilities[1]) { _1.pay_mana(generic: { green: 1 }, green: 2) }
    game.stack.resolve!
    game.tick!

    expect([figure.power, figure.toughness]).to eq([4, 5])
    expect(figure.type?("Soldier")).to be(true)
    expect(figure.type?("Scout")).to be(false)
  end

  it "{3}{G/W}{G/W}{G/W}: only a Soldier becomes a Kithkin Avatar 7/8 with protection from your opponents" do
    become_scout
    p1.add_mana(green: 3)
    p1.activate_ability(ability: figure.activated_abilities[1]) { _1.pay_mana(generic: { green: 1 }, green: 2) }
    game.stack.resolve!
    p1.add_mana(green: 6)
    p1.activate_ability(ability: figure.activated_abilities[2]) { _1.pay_mana(generic: { green: 3 }, green: 3) }
    game.stack.resolve!
    game.tick!

    expect([figure.power, figure.toughness]).to eq([7, 8])
    expect(figure.type?("Avatar")).to be(true)
    expect(figure.protected_from?(ResolvePermanent("Grizzly Bears", owner: p2))).to be(true)
    expect(figure.protected_from?(ResolvePermanent("Grizzly Bears", owner: p1))).to be(false)
  end

  it "the Avatar ability does nothing unless it's a Soldier" do
    p1.add_mana(green: 6)
    p1.activate_ability(ability: figure.activated_abilities[2]) { _1.pay_mana(generic: { green: 3 }, green: 3) }
    game.stack.resolve!
    game.tick!

    expect([figure.power, figure.toughness]).to eq([1, 1])
  end

  it "the changes last past the end of turn" do
    become_scout
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([figure.power, figure.toughness]).to eq([2, 3])
  end
end
