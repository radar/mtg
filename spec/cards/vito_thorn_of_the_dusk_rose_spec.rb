require 'spec_helper'

RSpec.describe Magic::Cards::VitoThornOfTheDuskRose do
  include_context "two player game"

  subject { ResolvePermanent("Vito, Thorn Of The Dusk Rose", owner: p1) }

  before do
    subject
  end

  it "makes target opponent lose life" do
    p1.gain_life(1)

    choice = game.choices.last
    expect(choice).to be_a(described_class::LifeLossChoice)
    choice.choose(p2)

    expect(p2.life).to eq(19)
  end

  context "activated abilities" do
    let!(:wood_elves) do
      ResolvePermanent("Wood Elves", owner: p1)
    end

    it "gives creatures lifelink until end of turn" do
      p1.add_mana(black: 5)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1.pay_mana(generic: { black: 3 }, black: 2)
      end

      game.stack.resolve!
      game.tick!

      expect(wood_elves.lifelink?).to eq(true)
      grant = wood_elves.keyword_grant_modifiers.last
      expect(grant.keyword_grant).to eq(Magic::Cards::Keywords::LIFELINK)
      expect(grant.until_eot?).to eq(true)
    end
  end
end
