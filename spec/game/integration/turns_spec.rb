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
    6.times.map { mountain.dup } + [raging_goblin, mountain.dup]
  end

  it "walks through two turns" do
    expect(p1.hand.count).to eq(7)
    expect(p2.hand.count).to eq(7)

    turn_1 = game.next_turn

    turn_1.untap!
    turn_1.upkeep!
    turn_1.draw!
    turn_1.first_main!

    #game.current_turn.possible_actions
    action = Magic::Actions::PlayLand.new(player: p1, card: p1.hand.by_name("Island").first)
    game.take_action(action)
    expect(p1.permanents.by_name("Island").count).to eq(1)
    expect(p1.lands_played).to eq(1)
    # 6 islands on game start draw, + aegis turtle
    # additional island on 1st turn draw - up to 7
    # one island played, down to 6 in hand
    expect(p1.hand.by_name("Island").count).to eq(6)

    island = p1.permanents.by_name("Island").first
    action = Magic::Actions::ActivateAbility.new(player: p1, permanent: island, ability: island.activated_abilities.first)
    game.take_action(action)
    expect(p1.mana_pool).to eq(blue: 1)

    island2 = p1.hand.by_name("Island").first
    action = Magic::Actions::PlayLand.new(player: p1, card: island2)
    expect(action.can_perform?).to eq(false)

    aegis_turtle = p1.hand.by_name("Aegis Turtle").first
    action = Magic::Actions::Cast.new(player: p1, card: aegis_turtle)
    action.pay_mana(blue: 1)
    game.take_action(action)
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

    action = Magic::Actions::PlayLand.new(player: p2, card: p2.hand.by_name("Mountain").first)
    game.take_action(action)
    mountain = p2.permanents.by_name("Mountain").first
    action = Magic::Actions::ActivateAbility.new(player: p1, permanent: mountain, ability: mountain.activated_abilities.first)
    game.take_action(action)
    expect(p2.mana_pool).to eq(red: 1)

    raging_goblin = p2.hand.by_name("Raging Goblin").first
    action = Magic::Actions::Cast.new(player: p2, card: raging_goblin)
    action.pay_mana(red: 1)
    game.take_action(action)

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

    game.next_active_player

    turn_3 = game.next_turn
    turn_3.untap!
    p1_island = game.battlefield.permanents.controlled_by(p1).by_name("Island").first
    expect(p1_island).to be_untapped

    turn_3.upkeep!
    turn_3.draw!
    turn_3.first_main!

    expect(p1.lands_played).to eq(0)
    island = p1.hand.by_name("Island").first
    action = Magic::Actions::Cast.new(player: p1, card: island)
    expect(action.can_perform?).to eq(true)
  end
end
