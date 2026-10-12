# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EchoingAssault do
  include_context "two player game"

  let!(:assault) { ResolvePermanent("Echoing Assault", owner: p1) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p1) } # 5/5 flying, lifelink, first strike

  def attack(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { |attacker| p1.declare_attacker(attacker: attacker, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  def copies = p1.creatures.select { _1.name == "Baneslayer Angel" && _1.token? }

  it "gives creature tokens you control menace" do
    token = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!
    game.tick!

    expect(token).to have_keyword(:menace)
  end

  it "does not give menace to nontoken creatures or an opponent's tokens" do
    theirs = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p2).resolve!
    game.tick!

    expect(angel).not_to have_keyword(:menace)
    expect(theirs).not_to have_keyword(:menace)
  end

  it "creates a tapped, attacking 1/1 copy of an attacking nontoken creature" do
    attack(angel)

    expect(game.choices).to be_empty
    expect(copies.count).to eq(1)
    expect([copies.first.power, copies.first.toughness]).to eq([1, 1])
    expect(copies.first).to be_tapped
    expect(current_turn.attacking?(copies.first)).to be true
    expect(copies.first).to be_flying
  end

  it "asks which creature when several are attacking" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack(angel, bears)

    choice = game.choices.last
    expect(choice.choices).to contain_exactly(angel, bears)
    game.resolve_choice!(target: bears)

    expect(p1.creatures.select { _1.name == "Grizzly Bears" && _1.token? }.count).to eq(1)
  end

  it "doesn't offer an attacking token" do
    token = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!
    game.settle!
    token.controlled_since_turn = 0
    attack(token)

    expect(game.choices).to be_empty
  end

  it "sacrifices the copy at the beginning of the next end step" do
    attack(angel)
    copy = copies.first
    current_turn.end!
    game.settle!

    expect(game.battlefield.permanents).not_to include(copy)
  end

  it "doesn't trigger on the opponent's attack" do
    game.next_turn
    expect(copies).to be_empty
  end
end
