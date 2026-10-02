# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurrogBefuddler do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Grizzly Bears", owner: p2) } # two legal targets, so the choice isn't auto-resolved
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/1 Frog Wizard with flash" do
    befuddler = ResolvePermanent("Burrog Befuddler", owner: p1)

    expect([befuddler.power, befuddler.toughness]).to eq([2, 1])
    expect(befuddler.card.has_keyword?(:flash)).to eq(true)
  end

  it "gives target creature an opponent controls -1/-0 until end of turn" do
    ResolvePermanent("Burrog Befuddler", owner: p1)
    game.resolve_choice!(target: rival)
    game.tick!

    expect([rival.power, rival.toughness]).to eq([1, 2])
  end

  it "wears off at end of turn" do
    ResolvePermanent("Burrog Befuddler", owner: p1)
    game.resolve_choice!(target: rival)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(rival.power).to eq(2)
  end

  it "can't target your own creatures" do
    ResolvePermanent("Burrog Befuddler", owner: p1)
    expect(game.choices.last.choices).not_to include(mine)
  end
end
