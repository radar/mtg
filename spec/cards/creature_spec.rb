require 'spec_helper'

RSpec.describe Magic::Cards::Creature do
  let(:game) { Magic::Game.new }
  subject { Card("Wood Elves") }


  context "with power modifiers" do
    let(:power_modifier) { double(:power_modifier, power: 1) }

    before do
      subject.modifiers << power_modifier
    end

    it "has those power modifiers removed when it leaves the battlefield" do
      expect(subject.power).to eq(2)
      subject.left_the_battlefield!
      expect(subject.modifiers).to be_empty
    end
  end

  context "with toughness modifiers" do
    let(:toughness_modifier) { double(:toughness_modifier, toughness: 1) }

    before do
      subject.modifiers << toughness_modifier
    end

    it "has those toughness modifiers removed when it leaves the battlefield" do
      expect(subject.toughness).to eq(2)
      subject.left_the_battlefield!
      expect(subject.modifiers).to be_empty
    end
  end

  context "attachments" do
    before do
      subject.attachments << attachment
    end

    context "with a generic attachment" do
      let(:attachment) { double(:attachment) }

      it "loses attachments when it leaves the battlefield" do
        subject.left_the_battlefield!
        expect(subject.attachments).to be_empty
      end
    end

    context "with an attachment that adds a type" do
      let(:attachment) { double(Magic::Aura, type_grants: ["Knight"]) }

      it "is considered a knight" do
        expect(subject.type?("Knight")).to eq(true)
      end
    end

    context "with an attachment that adds a keyword" do
      let(:attachment) { double(Magic::Aura, keyword_grants: [Magic::Card::Keywords::FIRST_STRIKE]) }

      it "has first strike" do
        expect(subject).to be_first_strike
      end
    end

    context "with an attachment that adds a power buff" do
      let(:attachment) { double(Magic::Aura, power_buff: 2) }

      it "has a power increase of 2" do
        expect(subject.power).to eq(3)
      end
    end

    context "with an attachment that adds a toughness buff" do
      let(:attachment) { double(Magic::Aura, toughness_buff: 2) }

      it "has a toughness increase of 2" do
        expect(subject.toughness).to eq(3)
      end

      context "with an attachment that prevents attacking" do
        let(:attachment) { double(Magic::Aura, can_attack?: false) }

        it "makes creature unable to attack" do
          expect(subject.can_attack?).to eq(false)
        end
      end

      context "with an attachment that prevents blocking" do
        let(:attachment) { double(Magic::Aura, can_block?: false) }

        it "makes creature unable to attack" do
          expect(subject.can_block?).to eq(false)
        end
      end
    end
  end
end
