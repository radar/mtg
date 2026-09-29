# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DawnhandDissident do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:dissident) { ResolvePermanent("Dawnhand Dissident", owner: p1) }
  let!(:holder) { ResolvePermanent("Courser Of Kruphix", owner: p1) } # 2/4, survives the blight

  it "is a 1/2 Elf Warlock" do
    expect(dissident.power).to eq(1)
    expect(dissident.toughness).to eq(2)
  end

  it "surveils 1 for {T}, Blight 1" do
    ability = dissident.activated_abilities.first
    p1.activate_ability(ability:) { |a| a.pay_blight(holder) }
    game.stack.resolve!

    expect(dissident).to be_tapped
    expect(holder.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  describe "exiling a card from a graveyard" do
    let(:dead_bears) { Card("Grizzly Bears", owner: p1) }

    before do
      p1.graveyard.add(dead_bears)
      ability = dissident.activated_abilities.last
      p1.activate_ability(ability:) { |a| a.pay_blight(holder).targeting(dead_bears) }
      game.stack.resolve!
    end

    it "exiles the target card for {T}, Blight 2" do
      expect(dead_bears.zone).to be_exile
      expect(holder.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
      expect(dissident.exiled_cards).to include(dead_bears)
    end

    it "lets you cast it during your turn by removing three counters from among your creatures" do
      # +1/+1 counters cancel the two -1/-1 counters from blighting (704.5q): 7 - 2 = 5.
      7.times { holder.add_counter(Magic::Counters::Plus1Plus1) }
      p1.add_mana(green: 2)

      p1.cast(card: dead_bears) do |a|
        a.pay_mana(generic: { green: 1 }, green: 1)
        a.pay_remove_counters([[holder, Magic::Counters::Plus1Plus1]] * 3)
      end
      game.stack.resolve!

      expect(holder.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
      expect(p1.creatures.count { |c| c.name == "Grizzly Bears" }).to eq(1)
    end

    it "cannot be cast without removing the counters" do
      3.times { holder.add_counter(Magic::Counters::Plus1Plus1) }
      p1.add_mana(green: 2)

      expect { p1.cast(card: dead_bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(RuntimeError, /Additional costs/)
    end

    it "cannot be cast during an opponent's turn" do
      3.times { holder.add_counter(Magic::Counters::Plus1Plus1) }
      p1.add_mana(green: 2)
      go_to_main_phase_for!(p2)

      expect(dead_bears.zone).to be_exile
      expect { p1.cast(card: dead_bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(Magic::IllegalAction)
    end
  end

  it "cannot cast a card exiled some other way" do
    other = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(other)
    trigger_exile = ResolvePermanent("Grizzly Bears", owner: p1)
    3.times { holder.add_counter(Magic::Counters::Plus1Plus1) }
    other.exile!
    p1.add_mana(green: 2)

    expect { p1.cast(card: other) { |a| a.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(Magic::IllegalAction)
    expect(trigger_exile).to be_a(Magic::Permanent)
  end
end
