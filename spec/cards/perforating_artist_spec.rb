# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PerforatingArtist do
  include_context "two player game"

  let!(:artist) { ResolvePermanent("Perforating Artist", owner: p1) }

  def attack_and_end_turn(attacker: artist)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    current_turn.end!
  end

  it "is a 3/2 Devil with deathtouch" do
    expect([artist.power, artist.toughness]).to eq([3, 2])
    expect(artist).to be_deathtouch
  end

  it "at your end step, if you attacked, has each opponent choose: lose 3 life, sacrifice a nonland permanent or discard" do
    attack_and_end_turn

    expect(game.choices.last).to be_a(Magic::Choice::LoseLifeUnless)
    game.skip_choice!
    expect(p2.life).to eq(20 - 3 - 3) # 3 combat damage from the Artist, 3 from declining
  end

  it "lets the opponent discard a card instead" do
    attack_and_end_turn
    card = p2.hand.cards.first
    game.resolve_choice!(discard: card)

    expect(p2.life).to eq(17)
    expect(p2.graveyard.cards).to include(card)
  end

  it "lets the opponent sacrifice a nonland permanent instead" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    attack_and_end_turn
    game.resolve_choice!(sacrifice: bears)

    expect(p2.life).to eq(17)
    expect(bears.card.zone).to be_graveyard
  end

  it "doesn't accept a land as the sacrifice (it just costs the life)" do
    mountain = ResolvePermanent("Mountain", owner: p2)
    attack_and_end_turn
    game.resolve_choice!(sacrifice: mountain)

    expect(p2.life).to eq(14)
    expect(mountain.zone).to be_battlefield
  end

  it "does nothing if you didn't attack this turn" do
    go_to_main_phase!
    current_turn.end!

    expect(game.choices).to be_empty
    expect(p2.life).to eq(20)
  end

  it "does not trigger at an opponent's end step" do
    go_to_main_phase_for!(p2)
    current_turn.end!

    expect(game.choices).to be_empty
  end
end
