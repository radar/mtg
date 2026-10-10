# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RaggedPlaymate do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:playmate) { ResolvePermanent("Ragged Playmate", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:ability) { playmate.activated_abilities.first }

  it "is a 2/2 Toy artifact creature" do
    expect([playmate.power, playmate.toughness]).to eq([2, 2])
    expect(playmate).to be_artifact
  end

  it "makes a creature with power 2 or less unblockable this turn" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability:) { |a| a.pay_mana(generic: { red: 1 }).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect(playmate).to be_tapped
    expect(bears.has_keyword?(Magic::Cards::Keywords::CANT_BE_BLOCKED)).to eq(true)
  end

  it "can't target a creature with power greater than 2" do
    big = ResolvePermanent("Serra Angel", owner: p1)
    p1.add_mana(red: 1)

    expect { p1.activate_ability(ability:) { |a| a.pay_mana(generic: { red: 1 }).targeting(big) } }.to raise_error(StandardError)
  end
end
