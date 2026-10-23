# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Drossclaw do
  include_context "two player game"

  before { go_to_main_phase! }

  def germ = p1.creatures.find { _1.name == "Phyrexian Germ" }

  it "creates a Germ and attaches itself to it, making it 1/1" do
    p1.add_mana(black: 2)
    p1.cast(card: Card("Drossclaw", owner: p1)) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
    game.tick!

    expect(germ).not_to be_nil
    expect([germ.power, germ.toughness]).to eq([1, 1])
  end

  context "when equipped to another creature" do
    let!(:drossclaw) { ResolvePermanent("Drossclaw", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      p1.add_mana(colorless: 2)
      p1.activate_ability(ability: drossclaw.activated_abilities.first) do
        _1.targeting(bears)
        _1.pay_mana(generic: { colorless: 2 })
      end
      game.stack.resolve!
      game.tick!
    end

    it "gives +1/+1" do
      expect([bears.power, bears.toughness]).to eq([3, 3])
    end

    it "makes each opponent lose 1 life when the equipped creature attacks" do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      current_turn.attackers_declared!
      game.settle!
      game.stack.resolve!
      game.settle!

      expect(p2.life).to eq(19)
    end
  end
end
