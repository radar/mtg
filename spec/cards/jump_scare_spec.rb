# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JumpScare do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.add_mana(white: 1)
    p1.cast(card: Card("Jump Scare", owner: p1)) do
      _1.auto_pay_mana
      _1.targeting(bears)
    end
    game.stack.resolve!
    game.tick!
  end

  it "gives the creature +2/+2 and flying" do
    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to be true
  end

  it "makes it a Horror enchantment in addition to its other types" do
    expect(bears.type?("Horror")).to be true
    expect(bears.type?("Enchantment")).to be true
    expect(bears.type?("Creature")).to be true
    expect(bears.type?("Bear")).to be true
  end

  it "wears off at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to be false
    expect(bears.type?("Horror")).to be false
  end
end
