# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AcademyManufactor do
  include_context "two player game"

  let!(:manufactor) { ResolvePermanent("Academy Manufactor", owner: p1) }

  def tokens_named(player, name)
    game.battlefield.controlled_by(player).select { |permanent| permanent.name == name }
  end

  def token_counts(player)
    %w[Clue Food Treasure].to_h { |name| [name, tokens_named(player, name).count] }
  end

  it "is a 1/3 Assembly-Worker artifact creature" do
    expect(manufactor.power).to eq(1)
    expect(manufactor.toughness).to eq(3)
    expect(manufactor.card.artifact?).to eq(true)
    expect(manufactor.card.creature?).to eq(true)
    expect(manufactor.card.types).to include(Magic::Types::Creatures["Assembly-Worker"])
  end

  it "creates one of each instead of a Treasure" do
    manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)

    expect(token_counts(p1)).to eq("Clue" => 1, "Food" => 1, "Treasure" => 1)
  end

  it "creates one of each instead of a Clue" do
    manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Clue)

    expect(token_counts(p1)).to eq("Clue" => 1, "Food" => 1, "Treasure" => 1)
  end

  it "creates that many of each when creating several Treasures" do
    manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure, amount: 2)

    expect(token_counts(p1)).to eq("Clue" => 2, "Food" => 2, "Treasure" => 2)
  end

  it "keeps the tokens tapped when the original would have entered tapped" do
    manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure, enters_tapped: true)

    expect(game.battlefield.controlled_by(p1).select(&:token?)).to all(be_tapped)
  end

  it "does not affect other tokens" do
    manufactor.trigger_effect(:create_token, token_class: Magic::Cards::AngelicAscension::AngelToken)

    expect(tokens_named(p1, "Angel").count).to eq(1)
    expect(token_counts(p1)).to eq("Clue" => 0, "Food" => 0, "Treasure" => 0)
  end

  it "does not affect tokens an opponent creates" do
    opponent_source = ResolvePermanent("Grizzly Bears", owner: p2)
    opponent_source.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)

    expect(token_counts(p2)).to eq("Clue" => 0, "Food" => 0, "Treasure" => 1)
  end

  it "applies again to each token with a second Academy Manufactor" do
    ResolvePermanent("Academy Manufactor", owner: p1)
    manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)

    expect(token_counts(p1)).to eq("Clue" => 3, "Food" => 3, "Treasure" => 3)
  end

  it "combines with Doubling Season" do
    ResolvePermanent("Doubling Season", owner: p1)
    manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)

    expect(token_counts(p1)).to eq("Clue" => 2, "Food" => 2, "Treasure" => 2)
  end

  context "with the created Food" do
    before do
      go_to_main_phase!
      manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)
    end

    it "gains 3 life when sacrificed" do
      food = tokens_named(p1, "Food").first
      p1.add_mana(red: 2)
      p1.activate_ability(ability: food.activated_abilities.first) do
        _1.pay_mana(generic: { red: 2 })
      end
      game.stack.resolve!

      expect(p1.life).to eq(23)
      expect(tokens_named(p1, "Food")).to be_empty
    end
  end

  context "with the created Clue" do
    before do
      go_to_main_phase!
      manufactor.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure)
    end

    it "draws a card when sacrificed" do
      clue = tokens_named(p1, "Clue").first
      p1.add_mana(red: 2)
      expect do
        p1.activate_ability(ability: clue.activated_abilities.first) do
          _1.pay_mana(generic: { red: 2 })
        end
        game.stack.resolve!
      end.to change { p1.hand.count }.by(1)
    end
  end
end
