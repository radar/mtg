# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HornOfGondor do
  include_context "two player game"

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  let!(:horn) { ResolvePermanent("Horn Of Gondor", owner: p1) }

  def activate
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: horn.activated_abilities.first) { |a| a.pay_mana(generic: { colorless: 3 }) }
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary artifact costing {3}" do
    card = Card("Horn Of Gondor")
    expect(card).to be_legendary
    expect(card.mana_value).to eq(3)
  end

  it "creates a 1/1 white Human Soldier token when it enters" do
    game.settle!
    expect(soldiers(p1).count).to eq(1)
    token = soldiers(p1).first
    expect(token.type?("Human")).to be(true)
    expect(token.colors).to include(:white)
    expect([token.power, token.toughness]).to eq([1, 1])
    expect(soldiers(p2)).to be_empty
  end

  it "creates X tokens, where X is the number of Humans you control" do
    game.settle!
    ResolvePermanent("Protector Of Gondor", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Protector Of Gondor", owner: p2)
    game.settle!
    # Humans: Horn's token, Protector and Protector's token = 3 (the opponent's Humans do not count)
    humans = p1.creatures.count { _1.type?("Human") }
    expect(humans).to eq(3)

    activate

    expect(p1.creatures.count { _1.type?("Human") }).to eq(humans + 3)
    expect(soldiers(p2).count).to eq(1) # only the opponent's own Protector token
    expect(horn).to be_tapped
  end

  it "cannot be activated again while tapped" do
    game.settle!
    activate
    expect(horn).to be_tapped
    p1.add_mana(colorless: 3)
    expect do
      p1.activate_ability(ability: horn.activated_abilities.first) { |a| a.pay_mana(generic: { colorless: 3 }) }
    end.to raise_error(StandardError)
  end
end
