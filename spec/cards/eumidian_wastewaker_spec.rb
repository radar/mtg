require "spec_helper"

RSpec.describe Magic::Cards::EumidianWastewaker do
  include_context "two player game"

  let!(:wastewaker) { ResolvePermanent("Eumidian Wastewaker", owner: p1) }

  it "is an Insect Cleric" do
    expect(wastewaker).to be_creature
  end

  def declare_attack!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: wastewaker, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def choose(player, card)
    choice = game.choices.first
    expect(choice.player).to eq(player)
    game.resolve_choice!(target: card)
  end

  let(:mine) { Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } }

  it "has you and the defending player each discard a card or sacrifice a permanent" do
    theirs = Card("Llanowar Elves", owner: p2).tap { p2.hand.add(_1) }
    mine
    declare_attack!

    choose(p1, mine)
    choose(p2, theirs)

    expect(p1.graveyard.cards).to include(mine)
    expect(p2.graveyard.cards).to include(theirs)
  end

  it "lets a player sacrifice a permanent instead" do
    forest = ResolvePermanent("Forest", owner: p2)
    declare_attack!

    choose(p1, wastewaker)
    choose(p2, forest)

    expect(p1.graveyard.by_name("Eumidian Wastewaker").count).to eq(1)
    expect(p2.graveyard.by_name("Forest").count).to eq(1)
  end

  context "encore {6}{B}{B}" do
    let(:encore_card) { Card("Eumidian Wastewaker", owner: p1) }

    def encore!
      p1.graveyard.add(encore_card)
      p1.add_mana(black: 8)
      p1.activate_ability(ability: encore_card.graveyard_abilities.first) { |a| a.pay_mana(generic: { black: 6 }, black: 2) }
      game.stack.resolve!
    end

    def tokens = p1.creatures.select { _1.token? && _1.name == "Eumidian Wastewaker" }

    before { go_to_main_phase! }

    it "exiles the card and creates a hasty token copy that must attack" do
      encore!

      expect(encore_card.zone).to be_exile
      expect(tokens.count).to eq(1)
      expect(tokens.first).to be_haste
      expect(tokens.first.must_attack?).to be(true)
    end

    it "sacrifices the token at the beginning of the next end step" do
      encore!
      current_turn.end!
      game.settle!

      expect(tokens).to be_empty
    end

    it "creates two tokens with Anointed Procession" do
      ResolvePermanent("Anointed Procession", owner: p1)
      encore!

      expect(tokens.count).to eq(2)
    end
  end

  it "draws you a card for each land card put into a graveyard this way" do
    land = Card("Forest", owner: p2).tap { p2.hand.add(_1) }
    mine
    declare_attack!

    choose(p1, mine)
    expect { choose(p2, land) }.to change { p1.hand.count }.by(1)
  end
end
