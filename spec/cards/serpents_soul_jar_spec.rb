# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SerpentsSoulJar do
  include_context "two player game"

  subject { ResolvePermanent("Serpent's Soul-Jar", owner: p1) }

  it "exiles an Elf you control when it dies" do
    subject
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    elf.mark_for_death!
    game.tick!

    expect(subject.exiled_cards.map(&:name)).to eq(["Llanowar Elves"])
    expect(elf.card.zone).to be_exile
  end

  it "does not exile a non-Elf creature you control that dies" do
    subject
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    bear.mark_for_death!
    game.tick!

    expect(subject.exiled_cards).to be_empty
  end

  it "does not exile an opponent's Elf that dies" do
    subject
    elf = ResolvePermanent("Llanowar Elves", owner: p2)
    elf.mark_for_death!
    game.tick!

    expect(subject.exiled_cards).to be_empty
  end

  it "lets you cast a creature spell from among exiled cards until end of turn by tapping and paying 2 life" do
    subject
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    elf.mark_for_death!
    game.tick!
    exiled_card = subject.exiled_cards.first
    2.times { game.next_turn }
    go_to_main_phase!

    ability = subject.activated_abilities.first
    p1.activate_ability(ability: ability)
    expect { game.stack.resolve! }.to change { p1.life }.by(-2)

    p1.add_mana(green: 1)
    p1.cast(card: exiled_card) { |a| a.pay_mana(green: 1) }
    game.stack.resolve!
    expect(exiled_card.zone).to be_battlefield
  end

  it "does not allow casting from exile without activating the ability" do
    subject
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    elf.mark_for_death!
    game.tick!
    exiled_card = subject.exiled_cards.first

    action = p1.prepare_cast(card: exiled_card)
    expect(action.can_perform?).to be false
  end
end
