# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RecklessPyrosurfer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:surfer) { ResolvePermanent("Reckless Pyrosurfer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def play_land!
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    p1.play_land(land: land)
    game.settle!
  end

  def attack!(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 2/2 Human Scout with haste" do
    expect([surfer.power, surfer.toughness]).to eq([2, 2])
    expect(surfer).to have_keyword(:haste)
    expect(surfer.type?("Scout")).to be(true)
  end

  it "gains battle cry when a land you control enters" do
    expect(surfer).not_to have_keyword(:battle_cry)
    play_land!

    expect(surfer).to have_keyword(:battle_cry)
  end

  it "does not gain battle cry when an opponent's land enters" do
    ResolvePermanent("Forest", owner: p2)
    game.settle!

    expect(surfer).not_to have_keyword(:battle_cry)
  end

  it "gives each other attacking creature +1/+0 when it attacks with battle cry" do
    play_land!
    attack!(surfer, bears)

    expect(bears.power).to eq(3)
    expect(surfer.power).to eq(2)
  end

  it "does not pump a creature that is not attacking" do
    play_land!
    attack!(surfer)

    expect(bears.power).to eq(2)
  end

  it "gives no bonus when attacking without battle cry" do
    attack!(surfer, bears)

    expect(bears.power).to eq(2)
  end

  it "stacks: each landfall is a separate instance of battle cry" do
    play_land!
    ResolvePermanent("Forest", owner: p1)
    game.settle!
    attack!(surfer, bears)

    expect(bears.power).to eq(4)
  end

  it "loses battle cry at end of turn" do
    play_land!
    current_turn.end!
    current_turn.cleanup!

    expect(surfer).not_to have_keyword(:battle_cry)
  end
end
