require 'spec_helper'

RSpec.describe Magic::Cards::AcidicSlime do
  include_context "two player game"

  subject { add_to_library("Acidic Slime", player: p1) }

  let(:land) { Permanent("Island", owner: p1) }
  let(:enchantment) { Permanent("Glorious Anthem", owner: p1) }
  let(:artifact) { Permanent("Sol Ring", owner: p1) }

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
      cast_and_resolve(card: subject, player: p1)
      effect = game.effects.first

      expect(effect).to be_a(Magic::Effects::DestroyTarget)
      expect(effect.choices).to match_array([land, enchantment, artifact])
    end
  end
end
