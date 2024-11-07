
require 'spec_helper'

RSpec.describe Magic::Cards::BasrisLieutenant do
  include_context "two player game"

  subject { ResolvePermanent("Basri's Lieutenant", owner: p1) }

  it "has vigilance" do
    expect(subject).to be_vigilant
  end

  it "has protection from multicolored" do
    multi_colored_card = instance_double(Magic::Card, multi_colored?: true)
    expect(subject.protected_from?(multi_colored_card)).to eq(true)
  end

  it "adds a counter to a target creature on enter", aggregate_failures: true do
    # Basri's Lieutenant ETB'd, is only creature under controller's control
    # Automatically allocated the +/+1 counter
    subject
    game.tick!
    expect(subject.power).to eq(4)
    expect(subject.toughness).to eq(5)
  end

  context "on death -- when basri's lieutenant is on the battlefield" do
    context "when the death is this card and it had a counter" do
      before do
        subject.add_counter(counter_type: Magic::Counters::Plus1Plus1)
      end

      it "creates a 2/2 white knight creature token with vigilance" do
        subject.destroy!
        expect(creatures.count).to eq(1)
        knight = creatures.first
        expect(knight.power).to eq(2)
        expect(knight.toughness).to eq(2)
        expect(knight.colors).to eq([:white])
        expect(knight).to be_vigilant
      end
    end

    context "when the death is another creature and it had a counter" do
      let(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
      before do
        subject
        elves.add_counter(counter_type: Magic::Counters::Plus1Plus1)
      end

      it "creates a 2/2 white knight creature token with vigilance" do
        elves.destroy!
        expect(creatures.count).to eq(2)
        knight = creatures.find { |creature| creature.name == "Knight" }
        expect(knight.power).to eq(2)
        expect(knight.toughness).to eq(2)
        expect(knight.colors).to eq([:white])
        expect(knight).to be_vigilant
      end
    end
  end
end
