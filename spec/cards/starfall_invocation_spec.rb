# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StarfallInvocation do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(gift:)
    card = Card("Starfall Invocation", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 5)
    p1.cast(card:) do |a|
      a.pay_mana(generic: { white: 3 }, white: 2)
      a.pay_kicker(nil) if gift
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys all creatures" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Baneslayer Angel", owner: p2)

    cast(gift: false)

    expect(mine.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(theirs.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(game.choices).to be_empty
  end

  it "does not give a card to the opponent without the gift" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect { cast(gift: false) }.not_to change { p2.hand.count }
  end

  it "gives the opponent a card, and returns your only dead creature (nothing to choose) when the gift was promised" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Baneslayer Angel", owner: p2)

    expect { cast(gift: true) }.to change { p2.hand.count }.by(1)

    expect(p1.permanents.by_name("Grizzly Bears").count).to eq(1)
    expect(p2.permanents.by_name("Baneslayer Angel").count).to eq(0)
  end

  it "lets you choose which of your creatures returns" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    elves = ResolvePermanent("Llanowar Elves", owner: p1)
    angel = ResolvePermanent("Baneslayer Angel", owner: p2)

    cast(gift: true)

    choice = game.choices.last
    expect(choice.choices).to contain_exactly(bears.card, elves.card)
    expect(choice.choices).not_to include(angel.card)
    game.resolve_choice!(target: elves.card)

    expect(p1.permanents.by_name("Llanowar Elves").count).to eq(1)
    expect(p1.permanents.by_name("Grizzly Bears").count).to eq(0)
  end

  it "forgets the gift for the next cast" do
    cast(gift: true)
    game.choices.clear

    expect(Card("Starfall Invocation", owner: p1).kicker_cost.paid?).to be false
  end

  it "has no choice when none of your creatures died" do
    ResolvePermanent("Baneslayer Angel", owner: p2)

    cast(gift: true)

    expect(game.choices).to be_empty
  end
end
