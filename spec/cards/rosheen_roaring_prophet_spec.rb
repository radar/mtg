# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RosheenRoaringProphet do
  include_context "two player game"

  it "is a 4/4 legendary Giant Shaman" do
    rosheen = ResolvePermanent("Rosheen, Roaring Prophet", owner: p1)
    game.skip_choice! if game.choices.any?

    expect([rosheen.power, rosheen.toughness]).to eq([4, 4])
    expect(rosheen.types.map(&:to_s)).to include("Legendary", "Creature")
    expect(rosheen.cmc).to eq(4)
  end

  describe "enters trigger" do
    let(:mind_spring) { Card("Mind Spring", owner: p1) }
    let(:volcanic_geyser) { Card("Volcanic Geyser", owner: p1) }
    let(:island) { Card("Island", owner: p1) }

    before do
      p1.library.add(island)
      p1.library.add(mind_spring)
      6.times { p1.library.add(Card("Island", owner: p1)) }
      p1.library.add(volcanic_geyser)
      p1.library.add(mind_spring)
    end

    it "mills six cards" do
      expect { ResolvePermanent("Rosheen, Roaring Prophet", owner: p1) }.to change { p1.graveyard.count }.by(6)
    end

    it "lets you put a card with {X} in its mana cost from among them into your hand" do
      ResolvePermanent("Rosheen, Roaring Prophet", owner: p1)
      choice = game.choices.first
      expect(choice.choices.map(&:name)).to all(satisfy { %w[Mind\ Spring Volcanic\ Geyser].include?(_1) })

      taken = choice.choices.first
      game.resolve_choice!(target: taken)

      expect(p1.hand.cards).to include(taken)
      expect(p1.graveyard.cards).not_to include(taken)
    end

    it "does not offer cards without {X}" do
      ResolvePermanent("Rosheen, Roaring Prophet", owner: p1)

      expect(game.choices.first.choices.map(&:name)).not_to include("Island")
    end

    it "may take nothing" do
      ResolvePermanent("Rosheen, Roaring Prophet", owner: p1)
      hand = p1.hand.count
      game.resolve_choice!(target: nil)

      expect(p1.hand.count).to eq(hand)
    end
  end

  describe "{T}: reveal cards with {X} in hand for restricted mana" do
    let!(:rosheen) do
      ResolvePermanent("Rosheen, Roaring Prophet", owner: p1).tap { game.skip_choice! if game.choices.any? }
    end
    let(:mind_spring) { Card("Mind Spring", owner: p1) }
    let(:geyser) { Card("Volcanic Geyser", owner: p1) }

    def activate!
      p1.activate_ability(ability: rosheen.activated_abilities.first)
      game.stack.resolve!
    end

    before do
      p1.hand.add(mind_spring)
      p1.hand.add(geyser)
      p1.hand.add(Card("Island", owner: p1))
    end

    it "only offers cards with {X} in their mana cost" do
      activate!

      expect(game.choices.first.choices).to contain_exactly(mind_spring, geyser)
    end

    it "adds {C}{C} for each card revealed" do
      activate!
      game.resolve_choice!(targets: [mind_spring, geyser])

      expect(p1.restricted_mana.size).to eq(4)
    end

    it "adds nothing when no cards are revealed" do
      activate!
      game.resolve_choice!(targets: [])

      expect(p1.restricted_mana).to be_empty
    end

    it "rejects a card without {X}" do
      activate!

      expect { game.resolve_choice!(targets: [p1.hand.cards.find { _1.name == "Island" }]) }.to raise_error(ArgumentError)
    end

    it "pays the X of an X spell" do
      go_to_main_phase!
      activate!
      game.resolve_choice!(targets: [mind_spring])
      p1.add_mana(blue: 2)

      p1.cast(card: mind_spring, value_for_x: 2) { |a| a.pay_mana(x: { colorless: 2 }, blue: 2) }
      game.stack.resolve!

      expect(p1.restricted_mana).to be_empty
    end

    it "cannot pay for a spell without {X}" do
      go_to_main_phase!
      activate!
      game.resolve_choice!(targets: [mind_spring])
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      p1.add_mana(green: 1)

      expect { p1.cast(card: bears) { |a| a.pay_mana(generic: { colorless: 1 }, green: 1) } }
        .to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "permits an ability with {X} in its mana cost" do
      use = Magic::Actions::AbilityUse.new(source: rosheen, mana_cost: Magic::Costs::Mana.new(x: 1, red: 1))

      expect(Magic::ManaRestriction::CostsWithX.new.permits?(use)).to eq(true)
    end

    it "does not permit an ability without {X} in its mana cost" do
      use = Magic::Actions::AbilityUse.new(source: rosheen, mana_cost: Magic::Costs::Mana.new("{2}{R}"))

      expect(Magic::ManaRestriction::CostsWithX.new.permits?(use)).to eq(false)
    end

    it "cannot be activated by an opponent" do
      expect { p2.activate_ability(ability: rosheen.activated_abilities.first) }.to raise_error(Magic::IllegalAction)
    end
  end
end
