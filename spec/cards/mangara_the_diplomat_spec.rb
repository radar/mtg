require 'spec_helper'

RSpec.describe Magic::Cards::MangaraTheDiplomat do
  include_context "two player game"

  subject(:mangara) { Card("Mangara, The Diplomat", controller: p2) }
  subject(:ugin) { Card("Ugin, The Spirit Dragon", controller: p2) }
  subject(:wood_elves_1) { Card("Wood Elves", controller: p1) }
  subject(:wood_elves_2) { Card("Wood Elves", controller: p1) }

  before do
    game.battlefield.add(mangara)
  end

  it "has lifelink" do
    expect(mangara.lifelink?).to eq(true)
  end

  context "whenever an opponent attacks... ability" do
    before do
      game.battlefield.add(ugin)
      game.battlefield.add(wood_elves_1)
      game.battlefield.add(wood_elves_2)
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
    it "p1 casts two wood elves, p2 draws" do
      expect(p2).to receive(:draw!)
      p1.add_mana({ green: 6 })
      action = Magic::Actions::Cast.new(player: p1, card: wood_elves_1)
      action.pay_mana(generic: { green: 2 }, green: 1)

      action_2 = Magic::Actions::Cast.new(player: p1, card: wood_elves_2)
      action_2.pay_mana(generic: { green: 2 }, green: 1)

      game.take_actions(action, action_2)
      game.tick!
    end
  end
end
