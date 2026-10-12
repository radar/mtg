# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Saw do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:saw) { ResolvePermanent("Saw", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def equip!
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: saw.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { colorless: 2 })
    end
    game.stack.resolve!
    game.tick!
  end

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "gives equipped creature +2/+0" do
    equip!

    expect([bears.power, bears.toughness]).to eq([4, 2])
  end

  it "may sacrifice another permanent when the equipped creature attacks; if you do, draw a card" do
    equip!
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)
    hand = p1.hand.count
    attack!
    game.resolve_choice!(sacrifice: fodder)
    game.settle!

    expect(fodder.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "draws nothing when you decline" do
    equip!
    ResolvePermanent("Grizzly Bears", owner: p1)
    hand = p1.hand.count
    attack!
    game.skip_choice!
    game.settle!

    expect(p1.hand.count).to eq(hand)
  end

  it "can't sacrifice the equipped creature or the Equipment" do
    equip!
    attack!

    expect(game.choices).to be_empty
  end

  it "does nothing when it isn't attached" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    attack!

    expect(game.choices).to be_empty
  end
end
