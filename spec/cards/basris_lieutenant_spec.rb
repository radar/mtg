require 'spec_helper'

RSpec.describe Magic::Cards::BasrisLieutenant do
  include_context "two player game"

  subject { Card("Basri's Lieutenant", controller: p1) }

  it "has vigilance" do
    expect(subject).to be_vigilant
  end

  it "has protection from multicolored" do
    multi_colored_card = double(Magic::Card, multi_colored?: true)
    expect(subject.protected_from?(multi_colored_card)).to eq(true)
  end

  it "adds a counter to a target creature on enter" do
    subject.resolve!
    game.stack.resolve!
    # Basri's Lieutenant ETB'd, is only creature under controller's control
    # Automatically allocated the +/+1 counter
    expect(subject.power).to eq(4)
    expect(subject.toughness).to eq(5)
  end

  context "on death -- when basri's lieutenant is on the battlefield" do
    before do
      subject.resolve!
    end

    context "when the death is this card and it had a counter" do
      let(:card) { subject }
      before do
        card.resolve!
        card.add_counter(toughness: 1, power: 1)
      end

      it "creates a 2/2 white knight creature token with vigilance" do
        card.destroy!
        expect(game.battlefield.creatures.count).to eq(1)
        knight = game.battlefield.creatures.first
        expect(knight.power).to eq(2)
        expect(knight.toughness).to eq(2)
        expect(knight.colors).to eq([:white])
        expect(knight).to be_vigilant
      end
    end

    context "when the death is another creature and it had a counter" do
      let(:card) { Card("Wood Elves", controller: p1) }
      before do
        card.resolve!
        card.add_counter(toughness: 1, power: 1)
      end

      it "creates a 2/2 white knight creature token with vigilance" do
        card.destroy!
        expect(game.battlefield.creatures.count).to eq(2)
        knight = game.battlefield.creatures.find { |creature| creature.name == "Knight" }
        expect(knight.power).to eq(2)
        expect(knight.toughness).to eq(2)
        expect(knight.colors).to eq([:white])
        expect(knight).to be_vigilant
      end
    end
  end
end
