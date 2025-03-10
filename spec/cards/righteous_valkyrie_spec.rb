require 'spec_helper'

RSpec.describe Magic::Cards::RighteousValkyrie do
  include_context "two player game"

  let!(:righteous_valkyrie) do
    ResolvePermanent("Righteous Valkyrie")
  end

  it "is a 2/4 angel cleric with flying" do
    expect(righteous_valkyrie).to be_a_creature
    expect(righteous_valkyrie.power).to eq(2)
    expect(righteous_valkyrie.toughness).to eq(4)
    expect(righteous_valkyrie).to have_keyword(:flying)
  end

  context "angel / cleric ability" do
    let(:anointed_chorister) { Card("Anointed Chorister") }

    it "gains 1 life" do
      p1.add_mana(white: 1)
      p1.cast(card: anointed_chorister) do
        _1.pay_mana(white: 1)
      end
      game.stack.resolve!
      game.tick!

      expect(p1.life).to eq(21)
    end
  end

  context "+2/+2 ability" do
    context "when player has only their starting life" do
      it "2nd ability does not trigger" do
        expect(righteous_valkyrie.power).to eq(2)
        expect(righteous_valkyrie.toughness).to eq(4)
      end
    end

    context "when player has 7 life more than their starting life" do
      before do
        p1.gain_life(7)
        game.tick!
      end

      it "2nd ability triggers" do
        expect(righteous_valkyrie.power).to eq(4)
        expect(righteous_valkyrie.toughness).to eq(6)
      end
    end
  end
end
