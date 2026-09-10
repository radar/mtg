# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NumaJoragaChieftain do
  include_context "two player game"

  let!(:numa) { ResolvePermanent("Numa, Joraga Chieftain", owner: p1) }

  it "is a legendary 2/2 Elf Warrior" do
    expect(numa.power).to eq(2)
    expect(numa.toughness).to eq(2)
    expect(numa.type?("Elf")).to be true
  end

  context "at the beginning of combat on the controller's turn" do
    before { game.notify!(Magic::Events::BeginningOfCombat.new(active_player: p1)) }

    it "offers to pay {X}{X}" do
      choice = game.choices.last
      expect(choice).to be_a(described_class::MayPayChoice)
    end

    it "distributes X +1/+1 counters among target Elves when paid" do
      elf = ResolvePermanent("Llanowar Elves", owner: p1)
      p1.add_mana(green: 4)

      game.resolve_choice!(x: 2, payment: { green: 4 })

      distribute_choice = game.choices.last
      expect(distribute_choice).to be_a(described_class::DistributeCountersChoice)
      expect(distribute_choice.choices).to include(elf, numa)

      game.resolve_choice!(distribution: { elf => 1, numa => 1 })
      game.tick!

      expect(elf.power).to eq(2)
      expect(numa.power).to eq(3)
    end

    it "does nothing when declined" do
      expect { game.skip_choice! }.not_to change { numa.counters.count }
    end
  end

  it "does not trigger on the opponent's combat" do
    game.notify!(Magic::Events::BeginningOfCombat.new(active_player: p2))
    expect(game.choices).to be_empty
  end
end
