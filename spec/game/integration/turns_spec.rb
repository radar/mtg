require 'spec_helper'

RSpec.describe Magic::Game::Turn, "turn walkthrough" do
  include_context "two player game"

  let(:island) { Card("Island") }
  let(:mountain) { Card("Mountain") }
  let(:aegis_turtle) { Card("Aegis Turtle") }
  let(:raging_goblin) { Card("Raging Goblin") }

  let(:p1_library) do
    6.times.map { island.dup } + [aegis_turtle, island.dup, aegis_turtle.dup]
  end

  let(:p2_library) do
    6.times.map { Card("Mountain", owner: p2) } + [Card("Raging Goblin", owner: p2), Card("Mountain", owner: p2)]
  end

  it "walks through two turns" do
    expect(p1.hand.count).to eq(7)
    expect(p2.hand.count).to eq(7)

    turn_1 = game.next_turn

    turn_1.untap!
    turn_1.upkeep!
    turn_1.draw!
    turn_1.first_main!

    p1.play_land(land: p1.hand.by_name("Island").first)
    expect(p1.permanents.by_name("Island").count).to eq(1)
    expect(p1.lands_played).to eq(1)
    # 6 islands on game start draw, + aegis turtle
    # additional island on 1st turn draw - up to 7
    # one island played, down to 6 in hand
    expect(p1.hand.by_name("Island").count).to eq(6)

    island = p1.permanents.by_name("Island").first
    p1.activate_ability(ability: island.activated_abilities.first)
    expect(p1.mana_pool).to eq(blue: 1)
    expect(island).to be_tapped

    island2 = p1.hand.by_name("Island").first
    action = p1.prepare_action(Magic::Actions::PlayLand, card: island2)
    expect(action.can_perform?).to eq(false)

    aegis_turtle = p1.hand.by_name("Aegis Turtle").first
    action = p1.cast(card: aegis_turtle) do |action|
      action.pay_mana(blue: 1)
    end

    game.stack.resolve!
    expect(p1.permanents.by_name("Aegis Turtle").count).to eq(1)

    turn_1.beginning_of_combat!
    turn_1.declare_attackers!
    turn_1.end_of_combat!
    turn_1.second_main!
    turn_1.end!

    turn_2 = game.next_turn

    expect(turn_2.active_player).to eq(p2)

    turn_2.untap!
    turn_2.upkeep!
    turn_2.draw!
    turn_2.first_main!

    p2.play_land(land: p2.hand.by_name("Mountain").first)
    mountain = p2.permanents.by_name("Mountain").first
    p2.activate_ability(ability: mountain.activated_abilities.first)
    expect(p2.mana_pool).to eq(red: 1)

    raging_goblin = p2.hand.by_name("Raging Goblin").first
    p2.cast(card: raging_goblin) do |action|
      action.pay_mana(red: 1)
    end

    game.stack.resolve!
    expect(p2.permanents.by_name("Raging Goblin").count).to eq(1)

    turn_2.beginning_of_combat!
    turn_2.declare_attackers!

    raging_goblin = p2.permanents.by_name("Raging Goblin").first
    turn_2.declare_attacker(
      raging_goblin,
      target: p1,
    )

    turn_2.attackers_declared!

    aegis_turtle = p1.permanents.by_name("Aegis Turtle").first
    turn_2.declare_blocker(
      aegis_turtle,
      attacker: raging_goblin,
    )

    turn_2.combat_damage!
    turn_2.end_of_combat!

    expect(aegis_turtle.zone).to be_battlefield
    expect(raging_goblin.zone).to be_battlefield
    expect(p2.life).to eq(20)

    turn_2.second_main!
    turn_2.end!

    turn_3 = game.next_turn
    turn_3.untap!
    p1_island = game.battlefield.permanents.controlled_by(p1).by_name("Island").first
    expect(p1_island).to be_untapped

    turn_3.upkeep!
    turn_3.draw!
    turn_3.first_main!

    expect(p1.lands_played).to eq(0)
  end
end
