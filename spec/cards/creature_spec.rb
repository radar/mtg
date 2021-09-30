require 'spec_helper'

RSpec.describe Magic::Cards::Creature do
  let(:game) { Magic::Game.new }
  subject { Card("Wood Elves") }


  context "with power modifiers" do
    let(:power_modifier) { double(:power_modifier, power: 1) }

    before do
      subject.power_modifiers << power_modifier
    end

    it "has those power modifiers removed when it leaves the battlefield" do
      expect(subject.power).to eq(2)
      subject.left_the_battlefield!
      expect(subject.power_modifiers).to be_empty
    end
  end

  context "with toughness modifiers" do
    let(:toughness_modifier) { double(:toughness_modifier, toughness: 1) }

    before do
      subject.toughness_modifiers << toughness_modifier
    end

    it "has those toughness modifiers removed when it leaves the battlefield" do
      expect(subject.toughness).to eq(2)
      subject.left_the_battlefield!
      expect(subject.toughness_modifiers).to be_empty
    end
  end
end
