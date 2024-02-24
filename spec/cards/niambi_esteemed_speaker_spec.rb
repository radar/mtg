require 'spec_helper'

RSpec.describe Magic::Cards::NiambiEsteemedSpeaker do
  include_context "two player game"

  let(:card) { Card("Niambi, Esteemed Speaker")}

  before do
    ResolvePermanent("Wood Elves", owner: p2)
  end

  it "has flash" do
    expect(card.flash?).to eq(true)
  end

  context "when it enters the battlefield" do
    it "chooses to return card to hand" do
      ResolvePermanent("Niambi, Esteemed Speaker", owner: p1)

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::NiambiEsteemedSpeaker::Choice)
      choice.choose(target: creatures.by_name("Wood Elves").first)

      expect(p1.life).to eq(23)
      expect(p2.hand.by_name("Wood Elves").count).to eq(1)
    end


    it "chooses to skip the choice" do
      ResolvePermanent("Niambi, Esteemed Speaker", owner: p1)

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::NiambiEsteemedSpeaker::Choice)
      p1.skip_choice(choice)
      expect(game.choices).to be_empty

      expect(p1.life).to eq(20)
      expect(creatures.by_name("Wood Elves").count).to eq(1)
    end
  end

  context "activated ability" do
    let!(:niambi) { ResolvePermanent("Niambi, Esteemed Speaker", owner: p1) }
    before do
      p1.skip_choice(game.choices.first)
      p1.hand.add(Card("Aron, Benalia's Ruin"))
    end

    it "draws two cards" do
      expect(p1).to receive(:draw!).twice

      aron = p1.hand.by_name("Aron, Benalia's Ruin").first
      p1.add_mana(white: 2, blue: 1)
      p1.activate_ability(ability: niambi.activated_abilities.first) do
        _1.pay_mana(white: 1, blue: 1, generic: { white: 1 })
        _1.pay_discard(aron)
      end

      game.tick!

      expect(aron.zone).to be_graveyard
    end
  end
end
