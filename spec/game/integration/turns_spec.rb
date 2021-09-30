require 'spec_helper'

RSpec.describe Magic::Game, "turn walkthrough" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
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
    subject.start!
    expect(p1.hand.count).to eq(7)
    expect(p2.hand.count).to eq(7)

    expect(subject.step).to be_untap
    subject.next_step

    expect(subject.step).to be_upkeep
    subject.next_step

    expect(subject.step).to be_draw
    subject.next_step
    expect(subject.step).to be_first_main

    island = p1.hand.find { |card| card.name == "Island" }
    p1.cast!(island)
    island.tap!
    expect(p1.lands_played).to eq(1)

    island2 = p1.hand.find { |card| card.name == "Island" }
    expect(p1.can_cast?(island2)).to eq(false)

    aegis_turtle = p1.hand.find { |card| card.name == "Aegis Turtle" }
    p1.pay_and_cast!({ blue: 1 }, aegis_turtle)
    game.stack.resolve!
    expect(aegis_turtle.zone).to be_battlefield

    subject.next_step
    expect(subject.step).to be_beginning_of_combat

    until subject.step.first_main?
      subject.next_step
    end

    expect(subject.active_player).to eq(p2)

    mountain = p2.hand.find { |card| card.name == "Mountain" }
    p2.cast!(mountain)
    mountain.tap!

    raging_goblin = p2.hand.find { |card| card.name == "Raging Goblin" }
    p2.pay_and_cast!({ red: 1 }, raging_goblin)
    game.stack.resolve!
    expect(raging_goblin.zone).to be_battlefield

    subject.next_step
    expect(subject.step).to be_beginning_of_combat

    subject.next_step
    expect(subject.step).to be_declare_attackers

    subject.declare_attacker(
      raging_goblin,
      target: p1,
    )

    subject.next_step
    expect(subject.step).to be_declare_blockers

    subject.declare_blocker(
      aegis_turtle,
      target: raging_goblin,
    )

    subject.next_step
    expect(subject.step).to be_first_strike

    subject.next_step
    expect(subject.step).to be_combat_damage
    expect(aegis_turtle.zone).to be_battlefield
    expect(raging_goblin.zone).to be_battlefield
    expect(p2.life).to eq(20)

    until subject.step.untap?
      subject.next_step
    end

    p1_island = subject.battlefield.cards.controlled_by(p1).find { |c| c.name == "Island" }
    expect(p1_island).to be_untapped

    until subject.step.first_main?
      subject.next_step
    end

    expect(p1.lands_played).to eq(0)
    island = p1.hand.find { |card| card.name == "Island" }
    expect(p1.can_cast?(island)).to be(true)
  end
end
