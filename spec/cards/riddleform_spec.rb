require "spec_helper"

RSpec.describe Magic::Cards::Riddleform do
  include_context "two player game"

  let!(:riddleform) { ResolvePermanent("Riddleform", owner: p1) }

  it "when a non-creature spell is cast" do
    p1.add_mana(red: 1)

    p1.cast(card: Card("Shock")) do
      _1.pay_mana(red: 1).targeting(p2)
    end

    game.tick!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Cards::Riddleform::Choice)

    game.resolve_choice!

    aggregate_failures do
      expect(riddleform).to be_a_creature
      expect(riddleform.types).to include("Enchantment")
      expect(riddleform.types).to include("Sphinx")
      expect(riddleform.power).to eq(3)
      expect(riddleform.toughness).to eq(3)
      expect(riddleform.flying?).to eq(true)
    end

    game.current_turn.end!
    game.current_turn.cleanup!

    aggregate_failures do
      expect(riddleform).not_to be_a_creature
      expect(riddleform.types).to include("Enchantment")
      expect(riddleform.types).not_to include("Sphinx")
      expect(riddleform.flying?).to eq(false)
    end
  end
end
