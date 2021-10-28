require 'spec_helper'

RSpec.describe Magic::Game::Turn, "turn walkthrough" do
  include_context "two player game"

  let(:island) { Card("Island") }
  let(:mountain) { Card("Mountain") }
  let(:aegis_turtle) { Card("Aegis Turtle") }
  let(:raging_goblin) { Card("Raging Goblin") }

  before do
    6.times { p1.library.add(island.dup) }
    p1.library.add(aegis_turtle)
    p1.library.add(island.dup)
    p1.library.add(aegis_turtle.dup)

    6.times { p2.library.add(mountain.dup) }
    p2.library.add(raging_goblin)
    p2.library.add(mountain.dup)
  end

  it "walks through two turns" do
    game.start!
    expect(p1.hand.count).to eq(7)
    expect(p2.hand.count).to eq(7)

    turn_1 = game.next_turn

    turn_1.upkeep!
    turn_1.draw!
    turn_1.first_main!

    island = p1.hand.by_name("Island").first
    p1.cast!(island)
    island.tap!
    expect(p1.lands_played).to eq(1)

    island2 = p1.hand.by_name("Island").first
    expect(p1.can_cast?(island2)).to eq(false)

    aegis_turtle = p1.hand.by_name("Aegis Turtle").first
    p1.pay_and_cast!({ blue: 1 }, aegis_turtle)
    game.stack.resolve!
    expect(aegis_turtle.zone).to be_battlefield

    turn_1.beginning_of_combat!
    turn_1.declare_attackers!
    turn_1.finish_combat!
    turn_1.second_main!
    turn_1.end!

    game.next_active_player
    turn_2 = game.next_turn

    expect(turn_2.active_player).to eq(p2)

    turn_2.upkeep!
    turn_2.draw!
    turn_2.first_main!

    mountain = p2.hand.by_name("Mountain").first
    p2.cast!(mountain)
    mountain.tap!

    raging_goblin = p2.hand.by_name("Raging Goblin").first
    p2.pay_and_cast!({ red: 1 }, raging_goblin)
    game.stack.resolve!
    expect(raging_goblin.zone).to be_battlefield

    turn_2.beginning_of_combat!
    turn_2.declare_attackers!

    turn_2.declare_attacker(
      raging_goblin,
      target: p1,
    )

    turn_2.declare_blockers!

    turn_2.declare_blocker(
      aegis_turtle,
      attacker: raging_goblin,
    )

    turn_2.first_strike!
    turn_2.combat_damage!
    turn_2.finish_combat!

    expect(aegis_turtle.zone).to be_battlefield
    expect(raging_goblin.zone).to be_battlefield
    expect(p2.life).to eq(20)

    turn_2.second_main!
    turn_2.end!

    game.next_active_player

    turn_3 = game.next_turn
    expect(turn_3).to be_at_step(:untap)
    p1_island = game.battlefield.cards.controlled_by(p1).by_name("Island").first
    expect(p1_island).to be_untapped

    turn_3.upkeep!
    turn_3.draw!
    turn_3.first_main!

    expect(p1.lands_played).to eq(0)
    island = p1.hand.by_name("Island").first
    expect(p1.can_cast?(island)).to be(true)
  end
end
