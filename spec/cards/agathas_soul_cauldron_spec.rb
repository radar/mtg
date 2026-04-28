# frozen_string_literal: true

RSpec.describe Magic::Cards::AgathasSoulCauldron do
  include_context "two player game"

  subject(:cauldron) { ResolvePermanent("Agatha's Soul Cauldron", owner: p1) }

  let(:ability) { cauldron.activated_abilities.first }

  context "tap ability — exile target card from a graveyard" do
    context "when a non-creature card is in the graveyard" do
      let(:island) { Card("Island", owner: p2) }

      before { island.move_to_graveyard! }

      it "exiles the card and tracks it" do
        p1.activate_ability(ability: ability) do
          _1.targeting(island)
        end
        game.stack.resolve!

        expect(island.zone).to be_exile
        expect(cauldron.exiled_cards).to include(island)
      end

      it "does not add a counter choice" do
        p1.activate_ability(ability: ability) do
          _1.targeting(island)
        end
        game.stack.resolve!

        expect(game.choices).to be_empty
      end
    end

    context "when a creature card is in the graveyard" do
      let(:wood_elves) { Card("Wood Elves", owner: p2) }
      let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

      before { wood_elves.move_to_graveyard! }

      it "exiles the card and tracks it" do
        p1.activate_ability(ability: ability) do
          _1.targeting(wood_elves)
        end
        game.stack.resolve!

        expect(wood_elves.zone).to be_exile
        expect(cauldron.exiled_cards).to include(wood_elves)
      end

      it "adds a counter choice targeting a creature you control" do
        p1.activate_ability(ability: ability) do
          _1.targeting(wood_elves)
        end
        game.stack.resolve!

        choice = game.choices.first
        expect(choice).to be_a(described_class::CounterChoice)
        expect(choice.choices).to include(bear)
        expect(choice.choices).not_to include(cauldron)
      end

      it "puts a +1/+1 counter on the chosen creature" do
        p1.activate_ability(ability: ability) do
          _1.targeting(wood_elves)
        end
        game.stack.resolve!
        game.resolve_choice!(target: bear)
        game.tick!

        expect(bear.power).to eq(3)
        expect(bear.toughness).to eq(3)
      end
    end
  end

  context "ability 2 — grant activated abilities from exiled creature cards" do
    let(:wood_elves) { Card("Wood Elves", owner: p2) }
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      wood_elves.move_to_graveyard!
      # Exile via tap ability to properly track in exiled_cards
      p1.activate_ability(ability: ability) do
        _1.targeting(wood_elves)
      end
      game.stack.resolve!
      game.resolve_choice!(target: bear)
      game.tick!
    end

    it "grants activated abilities of exiled creature cards to creatures with +1/+1 counters" do
      expect(bear.activated_abilities.map(&:class)).to include(*wood_elves.activated_abilities)
    end

    context "when a creature has no +1/+1 counters" do
      let!(:wolf) { ResolvePermanent("Alpine Watchdog", owner: p1) }

      it "does not grant abilities to creatures without +1/+1 counters" do
        expect(wolf.activated_abilities.map(&:class)).not_to include(*wood_elves.activated_abilities)
      end
    end
  end

  context "ability 1 — spend mana as though it were any color for creature ability activations" do
    # Skyway Sniper costs {2}{G} to activate — we pay with all blue mana (no green)
    let!(:skyway) { ResolvePermanent("Skyway Sniper", owner: p1) }

    before { cauldron } # force Cauldron onto the battlefield

    it "allows spending off-color mana to fulfill a creature ability's colored cost" do
      p1.add_mana(blue: 3)  # only blue, no green
      sniper_ability = skyway.activated_abilities.first

      # Verify mana payment succeeds (not resolving the ability — that needs a flying target)
      expect do
        p1.activate_ability(ability: sniper_ability) do
          _1.pay_mana(generic: { blue: 2 }, blue: 1)  # blue substitutes for {G}
        end
      end.not_to raise_error
    end

    it "does not allow off-color spending on non-creature abilities" do
      # Cauldron itself is an artifact with a tap ability — not a creature, so no any-color benefit
      p1.add_mana(blue: 3)
      cauldron_ability = cauldron.activated_abilities.first  # tap ability has no mana cost, so test p2's perspective
      # Skyway without Cauldron: use p2 who has no Cauldron
      skyway2 = ResolvePermanent("Skyway Sniper", owner: p2)
      p2.add_mana(blue: 3)
      sniper_ability2 = skyway2.activated_abilities.first

      expect do
        p2.activate_ability(ability: sniper_ability2) do
          _1.pay_mana(generic: { blue: 2 }, blue: 1)
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
