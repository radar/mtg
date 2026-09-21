# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VanquishersBanner do
  include_context "two player game"
  before { go_to_main_phase! }

  subject { ResolvePermanent("Vanquisher's Banner", owner: p1) }

  it "asks the controller to choose a creature type as it enters" do
    subject
    choice = game.choices.last
    expect(choice).to be_a(described_class::CreatureTypeChoice)
  end

  it "gives creatures you control of the chosen type +1/+1" do
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    subject
    game.resolve_choice!(creature_type: "Elf")
    game.tick!

    expect(elf.power).to eq(2)
    expect(elf.toughness).to eq(2)
  end

  it "does not buff creatures of a different type" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    subject
    game.resolve_choice!(creature_type: "Elf")
    game.tick!

    expect(bear.power).to eq(2)
  end

  it "draws a card whenever you cast a creature spell of the chosen type" do
    subject
    game.resolve_choice!(creature_type: "Elf")

    spell = Card("Llanowar Elves", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 1)
    draws_before = game.current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }
    p1.cast(card: spell) { |a| a.pay_mana(green: 1) }

    draws_after = game.current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }
    expect(draws_after - draws_before).to eq(1)
  end

  it "does not draw a card when casting a creature spell of a different type" do
    subject
    game.resolve_choice!(creature_type: "Elf")

    spell = Card("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)
    draws_before = game.current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

    draws_after = game.current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }
    expect(draws_after - draws_before).to eq(0)
  end
end
