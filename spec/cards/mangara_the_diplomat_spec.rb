require 'spec_helper'

RSpec.describe Magic::Cards::MangaraTheDiplomat do
  include_context "two player game"

  subject(:mangara) { Card("Mangara, The Diplomat", controller: p2) }
  subject(:ugin) { Card("Ugin, The Spirit Dragon", controller: p2) }
  subject(:wood_elves_1) { Card("Wood Elves", controller: p1) }
  subject(:wood_elves_2) { Card("Wood Elves", controller: p1) }

  before do
    game.battlefield.add(ugin)
    game.battlefield.add(mangara)
    game.battlefield.add(wood_elves_1)
    game.battlefield.add(wood_elves_2)
  end

  it "has lifelink" do
    expect(mangara.lifelink?).to eq(true)
  end

  context "whenever an opponent attacks... ability" do
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

end
