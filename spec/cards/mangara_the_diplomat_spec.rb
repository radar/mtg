require 'spec_helper'

RSpec.describe Magic::Cards::MangaraTheDiplomat do
  include_context "two player game"

  let!(:mangara) { ResolvePermanent("Mangara, The Diplomat", controller: p2) }

  it "has lifelink" do
    expect(mangara.lifelink?).to eq(true)
  end

  context "whenever an opponent attacks... ability" do
    let!(:wood_elves_1) { ResolvePermanent("Wood Elves", controller: p1) }
    let!(:wood_elves_2) { ResolvePermanent("Wood Elves", controller: p1) }
    let!(:ugin) { ResolvePermanent("Ugin, The Spirit Dragon", controller: p2) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!
    end

    it "when wood elves attack player" do
      current_turn.declare_attacker(
        wood_elves_1,
        target: p2,
      )

      current_turn.declare_attacker(
        wood_elves_2,
        target: p2,
      )

      expect(p2).to receive(:draw!)
      current_turn.attackers_declared!
    end

    it "when wood elves attack planeswalker" do
      current_turn.declare_attacker(
        wood_elves_1,
        target: ugin,
      )

      current_turn.declare_attacker(
        wood_elves_2,
        target: ugin,
      )

      expect(p2).to receive(:draw!)
      current_turn.attackers_declared!
    end
  end

  context "when opponent casts spell" do
    let!(:wood_elves_1) { Card("Wood Elves") }
    let!(:wood_elves_2) { Card("Wood Elves") }

    it "p1 casts two wood elves, p2 draws" do
      expect(p2).to receive(:draw!)
      p1.add_mana({ green: 6 })
      action = Magic::Actions::Cast.new(player: p1, card: wood_elves_1)
      p action.mana_cost
      action.pay_mana(generic: { green: 2 }, green: 1)

      action_2 = Magic::Actions::Cast.new(player: p1, card: wood_elves_2)
      p action_2.mana_cost
      action_2.pay_mana(generic: { green: 2 }, green: 1)

      game.take_actions(action, action_2)
      game.tick!
    end
  end
end
