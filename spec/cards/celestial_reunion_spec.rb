# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CelestialReunion do
  include_context "two player game"

  let(:card) { Card("Celestial Reunion", owner: p1) }
  let!(:elf) { Card("Wood Elves", owner: p1) } # mana value 3
  let!(:bears) { Card("Grizzly Bears", owner: p1) } # mana value 2
  let!(:angel) { Card("Baneslayer Angel", owner: p1) } # mana value 5

  before do
    [angel, bears, elf, Card("Forest", owner: p1)].each { p1.library.add(_1) } # the Forest is drawn for the turn
    p1.hand.add(card)
    go_to_main_phase!
  end

  def cast(x:, behold: nil)
    p1.add_mana(green: x + 1)
    p1.cast(card: card, value_for_x: x) do |a|
      a.pay_mana(green: 1, x: { green: x })
      a.pay_kicker(behold) if behold
    end
    game.stack.resolve!
  end

  it "searches for a creature card with mana value X or less and puts it into your hand" do
    cast(x: 3)
    expect(game.choices.last.choices).to contain_exactly(elf, bears)
    game.resolve_choice!(targets: [elf])

    expect(elf.zone).to be_hand
    expect(elf.zone).not_to be_battlefield
    expect(angel.zone).to be_library
  end

  it "finds nothing above X" do
    cast(x: 1)
    expect(game.choices.last.choices).to be_empty
  end

  context "when two creatures of a type were beheld" do
    let!(:elf_one) { ResolvePermanent("Wood Elves", owner: p1) }
    let(:elf_two) { Card("Wood Elves", owner: p1) }

    before { p1.hand.add(elf_two) }

    it "puts a found card of the chosen type onto the battlefield instead" do
      cast(x: 3, behold: { creature_type: "Elf", objects: [elf_one, elf_two] })
      game.resolve_choice!(targets: [elf])
      expect(elf.zone).to be_battlefield
    end

    it "puts a found card of another type into your hand" do
      cast(x: 3, behold: { creature_type: "Elf", objects: [elf_one, elf_two] })
      game.resolve_choice!(targets: [bears])
      expect(bears.zone).to be_hand
    end

    it "reveals the beheld card from your hand without moving it" do
      cast(x: 3, behold: { creature_type: "Elf", objects: [elf_one, elf_two] })
      expect(elf_two.zone).to be_hand
    end

    it "doesn't remember the behold for the next cast" do
      cast(x: 3, behold: { creature_type: "Elf", objects: [elf_one, elf_two] })
      game.resolve_choice!(targets: [bears])
      p1.hand.add(card)
      game.stack.resolve!
      cast(x: 3)
      game.resolve_choice!(targets: [elf])
      expect(elf.zone).to be_hand
    end
  end

  it "won't take two of the same permanent, or the wrong type" do
    elf_one = ResolvePermanent("Wood Elves", owner: p1)
    p1.add_mana(green: 2)
    expect do
      p1.cast(card: card, value_for_x: 1) do |a|
        a.pay_mana(green: 1, x: { green: 1 })
        a.pay_kicker(creature_type: "Elf", objects: [elf_one, elf_one])
      end
    end.to raise_error(/Behold 2 Elf creatures/)
    bears_permanent = ResolvePermanent("Grizzly Bears", owner: p1)
    expect do
      p1.cast(card: card, value_for_x: 1) do |a|
        a.pay_mana(green: 1, x: { green: 1 })
        a.pay_kicker(creature_type: "Elf", objects: [elf_one, bears_permanent])
      end
    end.to raise_error(/can't all be beheld/)
  end
end
