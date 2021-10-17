require 'spec_helper'

RSpec.describe Magic::Cards::FalconerAdept do
  let(:game) { Magic::Game.new }
  subject { Card("Falconer Adept") }

  context "when falconer is on the battlefield" do
    before do
      game.battlefield.add(subject)
    end

    it "attacks, creating a 1/1 white bird creature that is tapped and attacking" do
      subject.receive_notification(Magic::Events::AttackingCreature.new(creature: subject))
      expect(game.battlefield.creatures.count).to eq(2)
      bird = game.battlefield.creatures.find { |creature| creature.name == "Bird" }
      expect(bird.controller).to eq(subject.controller)
      expect(bird.colors).to eq([:white])
      expect(bird.power).to eq(1)
      expect(bird.toughness).to eq(1)
      expect(bird).to be_tapped
    end
  end
end
