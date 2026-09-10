# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SylvanMessenger do
  include_context "two player game"

  let(:elf_one) { Card("Wood Elves", owner: p1) }
  let(:elf_two) { Card("Elvish Mystic", owner: p1) }
  let(:mountain) { Card("Mountain", owner: p1) }
  let(:island) { Card("Island", owner: p1) }

  before do
    [elf_one, elf_two, mountain, island].reverse_each { |card| p1.library.add(card) }
  end

  subject!(:messenger) { ResolvePermanent("Sylvan Messenger", owner: p1) }

  it "is a 2/2 Elf with trample" do
    expect(messenger.power).to eq(2)
    expect(messenger.toughness).to eq(2)
    expect(messenger).to be_trample
    expect(messenger.card.types).to include("Elf")
  end

  it "puts revealed Elf cards into hand and the rest on the bottom of the library" do
    expect(p1.hand).to include(elf_one)
    expect(p1.hand).to include(elf_two)
    expect(p1.hand).not_to include(mountain)
    expect(p1.hand).not_to include(island)
    expect(p1.library.items.last(2)).to eq([mountain, island])
  end
end
