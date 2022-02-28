require 'spec_helper'

RSpec.describe Magic::Cards::AcidicSlime do
  let(:game) { Magic::Game.start! }
  subject { Card("Acidic Slime") }

  let(:land) { Card("Island") }
  let(:enchantment) { Card("Glorious Anthem") }
  let(:artifact) { Card("Sol Ring") }

  it "has deathtouch" do
    expect(subject).to be_deathtouch
  end

  context "when acidic slime enters the battlefield" do
    before do
      game.battlefield.add(land)
      game.battlefield.add(enchantment)
      game.battlefield.add(artifact)
    end

    it "triggers a destroy effect" do
      subject.cast!
      game.stack.resolve!
      effect = game.effects.first

      expect(effect).to be_a(Magic::Effects::SingleTargetAndResolve)
      expect(effect.choices).to match_array([land, enchantment, artifact])
    end
  end
end
