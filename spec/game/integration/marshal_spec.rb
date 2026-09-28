# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Marshalling a game" do
  include_context "two player game"

  before { go_to_main_phase! }

  def round_trip(game) = Marshal.load(Marshal.dump(game))

  it "round-trips a fresh mid-game state" do
    ResolvePermanent("Forest", owner: p1)
    copy = round_trip(game)

    expect(copy.players.map(&:name)).to eq(%w[P1 P2])
    expect(copy.battlefield.permanents.count).to eq(1)
    expect(copy.current_turn.number).to eq(game.current_turn.number)
    expect(copy.current_turn.main_phase?).to eq(true)
    expect(copy.players.first.hand.count).to eq(p1.hand.count)
  end

  it "does not dump the logger" do
    game.logger
    expect(Marshal.dump(game)).not_to include("Logger")
  end

  it "gives the loaded game a working logger" do
    copy = round_trip(game)
    expect(copy.logger).to be_a(Logger)
    expect(copy.stack.logger).to equal(copy.logger)
  end

  it "keeps a loaded game playable" do
    copy = round_trip(game)
    player = copy.players.first
    land = player.hand.find(&:land?)

    player.play_land(land:)

    expect(copy.battlefield.permanents.map(&:name)).to eq(["Forest"])
    active = copy.current_turn.active_player
    copy.next_turn
    expect(copy.current_turn.active_player).not_to eq(active)
  end

  it "round-trips a game holding a mana cost adjustment" do
    ResolvePermanent("Foundry Inspector", owner: p1)
    copy = round_trip(game)
    inspector = copy.battlefield.permanents.find { |permanent| permanent.name == "Foundry Inspector" }

    ability = inspector.static_abilities.first
    expect(ability.applies_to?(Magic::Cards::FoundryInspector.new(game: copy, owner: copy.players.first))).to eq(true)
  end

  it "round-trips a spell on the stack" do
    p1.hand.add(Card("Lightning Bolt", owner: p1))
    bolt = p1.hand.find { |c| c.name == "Lightning Bolt" }
    add_mana_to_p1 = p1.method(:add_mana)
    add_mana_to_p1.call(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }

    copy = round_trip(game)
    expect(copy.stack.count).to eq(1)
    copy.stack.resolve!
    expect(copy.players.last.life).to eq(17)
  end
end
