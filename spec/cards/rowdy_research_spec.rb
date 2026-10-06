# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RowdyResearch do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Rowdy Research", owner: p1) }

  def attack_with(creature)
    game.notify!(Magic::Events::CreatureAttacked.new(attacker: creature, target: p2))
  end

  def cost_for(spell) = Magic::Actions::Cast.new(game: game, player: p1, card: spell).mana_cost.cost.to_h

  it "costs {6}{U} with no attackers" do
    expect(cost_for(card)).to eq(generic: 6, blue: 1)
  end

  it "costs {1} less for each creature that attacked this turn" do
    a = ResolvePermanent("Grizzly Bears", owner: p1)
    b = ResolvePermanent("Grizzly Bears", owner: p2)
    attack_with(a)
    attack_with(b)

    expect(cost_for(card)).to eq(generic: 4, blue: 1)
  end

  it "counts a creature once however many times it attacks" do
    a = ResolvePermanent("Grizzly Bears", owner: p1)
    2.times { attack_with(a) }

    expect(cost_for(card)).to eq(generic: 5, blue: 1)
  end

  it "draws three cards" do
    p1.hand.add(card)
    p1.add_mana(blue: 1, red: 6)

    expect do
      p1.cast(card:) { |a| a.pay_mana(generic: { red: 6 }, blue: 1) }
      game.stack.resolve!
    end.to change { p1.hand.count }.by(2) # three drawn, the spell leaves the hand
  end
end
