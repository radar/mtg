# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RallyAtTheHornburg do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Rally At The Hornburg", owner: p1) }

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  def cast_rally
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card: card) { _1.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.tick!
  end

  it "creates two 1/1 white Human Soldier tokens" do
    cast_rally
    expect(soldiers(p1).count).to eq(2)
    soldiers(p1).each do |token|
      expect(token.type?("Human")).to be(true)
      expect(token.colors).to include(:white)
      expect([token.power, token.toughness]).to eq([1, 1])
    end
    expect(soldiers(p2)).to be_empty
    expect(card.zone).to eq(p1.graveyard)
  end

  it "gives Humans you control haste, including the new tokens and summoning-sick Humans" do
    human = ResolvePermanent("Protector Of Gondor", owner: p1, summoning_sick: true)
    game.settle!
    existing = soldiers(p1).count
    cast_rally
    expect(human.haste?).to be(true)
    expect(soldiers(p1).count).to eq(existing + 2)
    expect(soldiers(p1).all?(&:haste?)).to be(true)
  end

  it "does not give haste to non-Humans or to the opponent's Humans" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    enemy = ResolvePermanent("Protector Of Gondor", owner: p2)
    cast_rally
    expect(bear.haste?).to be(false)
    expect(enemy.haste?).to be(false)
  end

  it "loses haste at end of turn" do
    human = ResolvePermanent("Protector Of Gondor", owner: p1, summoning_sick: true)
    cast_rally
    expect(human.haste?).to be(true)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(human.haste?).to be(false)
  end
end
