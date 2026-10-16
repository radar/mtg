# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EladamriKorvecdal do
  include_context "two player game"

  let!(:eladamri) { ResolvePermanent("Eladamri, Korvecdal", owner: p1) }

  before { go_to_main_phase! }

  it "is a legendary 3/3 Elf Warrior" do
    expect([eladamri.power, eladamri.toughness]).to eq([3, 3])
    expect(eladamri.card).to be_legendary
    expect(eladamri.type?("Elf")).to be(true)
    expect(eladamri.type?("Warrior")).to be(true)
  end

  context "look at the top card of your library any time" do
    it "marks only its controller as able to look" do
      ability = eladamri.static_abilities.first

      expect(ability.may_look_at_top_card?(p1)).to be(true)
      expect(ability.may_look_at_top_card?(p2)).to be(false)
    end
  end

  context "cast creature spells from the top of your library" do
    it "allows casting a creature on top" do
      creature = Card("Grizzly Bears", owner: p1)
      p1.library.add(creature, 0)
      p1.add_mana(generic: 1, green: 1)

      expect(p1.prepare_cast(card: creature).can_perform?).to be(true)
    end

    it "does not allow casting a noncreature on top" do
      spell = Card("Lightning Bolt", owner: p1)
      p1.library.add(spell, 0)
      p1.add_mana(red: 1)

      expect(p1.prepare_cast(card: spell).can_perform?).to be(false)
    end

    it "does not allow casting a creature that is not on top" do
      creature = Card("Grizzly Bears", owner: p1)
      p1.library.add(creature, 0)
      p1.library.add(Card("Forest", owner: p1), 0)
      p1.add_mana(generic: 1, green: 1)

      expect(p1.prepare_cast(card: creature).can_perform?).to be(false)
    end

    it "does not let the opponent cast from the top of their library" do
      creature = Card("Grizzly Bears", owner: p2)
      p2.library.add(creature, 0)
      p2.add_mana(generic: 1, green: 1)

      expect(p2.prepare_cast(card: creature).can_perform?).to be(false)
    end
  end

  context "{G}, {T}, Tap two untapped creatures you control: reveal a card" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:cub) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def activate(player: p1, taps: [bears, cub])
      player.add_mana(green: 1)
      player.activate_ability(ability: eladamri.activated_abilities.first) do |a|
        a.pay_mana(green: 1)
        a.pay_multi_tap(taps)
      end
    end

    it "puts a revealed creature card from hand onto the battlefield" do
      creature = Card("Raging Goblin", owner: p1)
      p1.hand.add(creature)
      activate
      game.stack.resolve!
      game.resolve_choice!(card: creature)
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Raging Goblin")
      expect(eladamri).to be_tapped
      expect(bears).to be_tapped
      expect(cub).to be_tapped
    end

    it "puts a revealed creature card from the top of the library onto the battlefield" do
      creature = Card("Raging Goblin", owner: p1)
      p1.library.add(creature, 0)
      activate
      game.stack.resolve!
      game.resolve_choice!(card: creature)
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Raging Goblin")
      expect(p1.library.cards).not_to include(creature)
    end

    it "leaves a revealed noncreature card where it is" do
      land = Card("Forest", owner: p1)
      p1.library.add(land, 0)
      activate
      game.stack.resolve!
      game.resolve_choice!(card: land)
      game.settle!

      expect(p1.library.first).to eq(land)
      expect(p1.lands.map(&:card)).not_to include(land)
    end

    it "needs two other untapped creatures" do
      cub.tap!

      expect { activate(taps: [bears, cub]) }.to raise_error(StandardError)
      expect(eladamri).not_to be_tapped
    end

    it "can only be activated during your turn" do
      go_to_main_phase_for!(p2)

      expect { activate }.to raise_error(Magic::IllegalAction)
      expect(bears).not_to be_tapped
      expect(cub).not_to be_tapped
    end

    it "cannot be activated by the opponent" do
      p2.add_mana(green: 1)

      expect do
        p2.activate_ability(ability: eladamri.activated_abilities.first) do |a|
          a.pay_mana(green: 1)
          a.pay_multi_tap([bears, cub])
        end
      end.to raise_error(Magic::IllegalAction, /does not control/)
      expect(bears).not_to be_tapped
      expect(eladamri).not_to be_tapped
    end
  end
end
