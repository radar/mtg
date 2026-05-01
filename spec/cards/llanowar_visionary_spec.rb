# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::LlanowarVisionary do
  include_context "two player game"

  let(:forest) { Card("Forest") }

  before do
    p1.library.add(forest)
  end

  subject { ResolvePermanent("Llanowar Visionary", owner: p1) }

  context "ETB effect" do
    it "controller draws a card" do
      expect(p1).to receive(:draw!)
      subject
    end
  end

  context "stats" do
    it "is a 2/2" do
      expect(subject.power).to eq(2)
      expect(subject.toughness).to eq(2)
    end
  end

  context "mana ability" do
    it "taps for one green mana" do
      p1.activate_ability(ability: subject.activated_abilities.first)
      expect(p1.mana_pool[:green]).to eq(1)
    end
  end
end
