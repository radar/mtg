# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Goremand do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_goremand
    card = Card("Goremand", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 6)
    p1.cast(card:) do |a|
      a.pay_mana(generic: { black: 4 }, black: 2)
      a.pay_sacrifice(fodder)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 5/5 flying trampling Demon" do
    cast_goremand
    goremand = p1.creatures.by_name("Goremand").first

    expect([goremand.power, goremand.toughness]).to eq([5, 5])
    expect(goremand).to be_flying
    expect(goremand.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
  end

  it "requires sacrificing a creature as an additional cost" do
    card = Card("Goremand", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 6)

    expect { p1.cast(card:) { |a| a.pay_mana(generic: { black: 4 }, black: 2) } }.to raise_error("Additional costs have not been paid")
  end

  it "makes each opponent sacrifice a creature when it enters" do
    cast_goremand
    game.resolve_choice!(target: victim)

    expect(fodder.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(victim.zone).not_to be_a(Magic::Zones::Battlefield)
  end
end
