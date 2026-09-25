# frozen_string_literal: true

require "spec_helper"
require_relative "../../card_parser/card_parser_helpers"

RSpec.describe "Targeting keywords: hexproof, shroud, protection and ward" do
  include CardParserHelpers
  include_context "two player game"

  def creature(text, owner:)
    name = text.lines.first[/\A(.+?) \{/, 1]
    load_card(text)
    ResolvePermanent(name, owner: owner)
  end

  def shock(player)
    player.add_mana(red: 1)
    player.cast(card: Card("Shock", owner: player)) { |action| yield action.pay_mana(red: 1) }
  end

  context "hexproof" do
    let!(:target) { creature("Hexproof Test Bear {1}{G}\nCreature — Bear\nHexproof\n2/2\n", owner: p1) }

    it "stops an opponent's spell from targeting it" do
      expect { shock(p2) { _1.targeting(target) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end

    it "lets its controller target it" do
      expect { shock(p1) { _1.targeting(target) } }.not_to raise_error
    end

    it "stops an opponent's activated ability from targeting it" do
      dart = ResolvePermanent("Silent Dart", owner: p2)
      p2.add_mana(black: 4)
      ability = dart.activated_abilities.first

      expect { p2.activate_ability(ability: ability) { _1.targeting(target) } }.to raise_error(/Invalid target/)
    end
  end

  context "hexproof from a color" do
    let!(:target) { creature("Hexproof From Red Test Bear {1}{G}\nCreature — Bear\nHexproof from red\n2/2\n", owner: p1) }

    it "stops an opponent's red spell" do
      expect { shock(p2) { _1.targeting(target) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end

    it "does not stop a colorless source" do
      dart = ResolvePermanent("Silent Dart", owner: p2)
      ability = dart.activated_abilities.first
      p2.add_mana(black: 4)

      p2.activate_ability(ability: ability) do
        _1.targeting(target).pay_mana(generic: { black: 4 }).pay(:self_sacrifice, dart)
      end

      expect(game.stack.count).to eq(1)
    end
  end

  context "shroud" do
    let!(:target) { creature("Shroud Test Bear {1}{G}\nCreature — Bear\nShroud\n2/2\n", owner: p1) }

    it "stops an opponent from targeting it" do
      expect { shock(p2) { _1.targeting(target) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end

    it "stops its controller from targeting it" do
      expect { shock(p1) { _1.targeting(target) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end
  end

  context "protection from red" do
    let!(:target) { creature("Protection Test Bear {1}{W}\nCreature — Bear\nProtection from red\n2/2\n", owner: p1) }

    it "stops a red spell, even from its controller" do
      expect { shock(p1) { _1.targeting(target) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end

    it "does not stop a spell of another color" do
      p2.add_mana(black: 2)
      expect do
        p2.cast(card: Card("Doom Blade", owner: p2)) { _1.pay_mana(generic: { black: 1 }, black: 1).targeting(target) }
      end.not_to raise_error
    end
  end

  context "ward {2}" do
    let!(:target) { creature("Ward Test Bear {1}{G}\nCreature — Bear\nWard {2}\n2/2\n", owner: p1) }

    context "targeted by a spell" do
      before { shock(p2) { _1.targeting(target) } }

      it "asks the opponent to pay" do
        expect(game.choices.last).to be_a(Magic::Choice::Ward)
      end

      it "counters the spell when the opponent does not pay" do
        game.resolve_choice!(payment: {})

        expect(game.stack.spells).to be_empty
      end

      it "leaves the spell alone when the opponent pays" do
        p2.add_mana(red: 2)
        game.resolve_choice!(payment: { red: 2 })

        expect(game.stack.spells.count).to eq(1)
        expect(p2.mana_pool[:red]).to eq(0)
      end
    end

    context "targeted by an activated ability" do
      let!(:dart) { ResolvePermanent("Silent Dart", owner: p2) }

      before do
        p2.add_mana(black: 4)
        p2.activate_ability(ability: dart.activated_abilities.first) do
          _1.targeting(target).pay_mana(generic: { black: 4 }).pay(:self_sacrifice, dart)
        end
      end

      it "asks the opponent to pay" do
        expect(game.choices.last).to be_a(Magic::Choice::Ward)
      end

      it "counters the ability when the opponent does not pay" do
        game.resolve_choice!(payment: {})
        game.stack.resolve!

        expect(target.damage).to eq(0)
      end

      it "lets the ability resolve when the opponent pays" do
        p2.add_mana(black: 2)
        game.resolve_choice!(payment: { black: 2 })
        game.stack.resolve!
        game.tick!

        expect(target.damage).to eq(3)
      end
    end

    it "does not trigger for its controller's own spell" do
      shock(p1) { _1.targeting(target) }

      expect(game.choices).to be_empty
    end
  end
end
