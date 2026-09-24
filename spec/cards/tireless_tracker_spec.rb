# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TirelessTracker do
  include_context "two player game"

  let!(:tracker) { ResolvePermanent("Tireless Tracker", owner: p1) }

  def clues = p1.permanents.by_name("Clue")

  it "investigates whenever a land you control enters" do
    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Forest", owner: p2)

    expect(clues.count).to eq(1)
    expect(clues.first.type?("Clue")).to eq(true)
  end

  it "draws from a sacrificed Clue, and gets a +1/+1 counter" do
    ResolvePermanent("Forest", owner: p1)
    p1.add_mana(green: 2)

    expect do
      p1.activate_ability(ability: clues.first.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }) }
      game.stack.resolve!
    end.to change { p1.hand.count }.by(1)

    game.tick!
    expect(clues).to be_empty
    expect(tracker.power).to eq(4)
  end

  it "doesn't grow when an opponent sacrifices their Clue" do
    clue = Magic::Tokens::Clue.new(game: game, owner: p2).resolve!
    p2.add_mana(blue: 2)
    p2.activate_ability(ability: clue.activated_abilities.first) { _1.pay_mana(generic: { blue: 2 }) }
    game.stack.resolve!
    game.tick!

    expect(clue.zone).to be_nil
    expect(tracker.power).to eq(3)
  end
end
