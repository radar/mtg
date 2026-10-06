# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Actions::Cast, "choosing modes" do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:command) { Card("Brigids Command", owner: p1) }
  let(:modes) { Magic::Cards::BrigidsCommand }
  let(:farmer) { ResolvePermanent("Wary Farmer", owner: p1) }

  def cast(&block)
    p1.hand.add(command)
    p1.add_mana(green: 2, white: 1)
    p1.cast(card: command) do |action|
      action.pay_mana(green: 1, white: 1, generic: { green: 1 })
      block.call(action)
    end
  end

  it "requires exactly two modes for a \"choose two\" spell" do
    expect(command.modes_to_choose).to eq(2)
  end

  it "raises when fewer than two modes are chosen" do
    expect {
      cast { |action| action.choose_mode(modes::Pump) { _1.targeting(farmer) } }
    }.to raise_error(described_class::InvalidModes, /needs 2 modes chosen, got 1/)
  end

  it "raises when no mode is chosen" do
    expect { cast { |_action| } }.to raise_error(described_class::InvalidModes, /got 0/)
  end

  it "raises when a third mode is chosen" do
    expect {
      cast do |action|
        action.choose_mode(modes::Pump) { _1.targeting(farmer) }
        action.choose_mode(modes::CreateKithkin) { _1.targeting(p1) }
        action.choose_mode(modes::CopyKithkin) { _1.targeting(farmer) }
      end
    }.to raise_error(described_class::InvalidModes, /at most 2/)
  end

  it "raises when the same mode is chosen twice" do
    expect {
      cast do |action|
        action.choose_mode(modes::Pump) { _1.targeting(farmer) }
        action.choose_mode(modes::Pump) { _1.targeting(farmer) }
      end
    }.to raise_error(described_class::InvalidModes, /already chosen/)
  end

  it "raises for a mode that belongs to a different card" do
    expect {
      cast { |action| action.choose_mode(Magic::Cards::SyggsCommand::Draw) { _1.targeting(p1) } }
    }.to raise_error(described_class::InvalidModes, /not a mode of/)
  end

  it "doesn't spend a spell cast or put the spell on the stack when the modes are wrong" do
    expect { cast { |_action| } }.to raise_error(described_class::InvalidModes)

    expect(game.stack.spells).to be_empty
  end

  it "leaves cards that don't declare a mode count unenforced" do
    expect(Card("Casualties Of War")).not_to respond_to(:modes_to_choose)
  end
end
