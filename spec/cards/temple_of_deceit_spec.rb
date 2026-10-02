# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TempleOfDeceit do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) do
    p1.play_land(land: Card("Temple Of Deceit"))
    game.settle!
    p1.permanents.by_name("Temple of Deceit").first
  end

  it "enters the battlefield tapped" do
    expect(permanent).to be_tapped
  end

  it "scries 1 when it enters" do
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Scry)

    bottomed = choice.choices.first
    game.resolve_choice!(bottom: [bottomed])

    expect(p1.library.cards.last).to eq(bottomed)
  end

  it "taps for blue" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:blue) }

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "taps for black" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:black) }

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "can't tap for another colour" do
    permanent.untap!

    expect { p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) } }
      .to raise_error(/Invalid choice made for mana ability/)
  end
end
