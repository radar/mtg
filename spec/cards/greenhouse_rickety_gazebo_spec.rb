# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GreenhouseRicketyGazebo do
  include_context "two player game"

  context "Greenhouse" do
    let!(:room) { ResolvePermanent("Greenhouse Rickety Gazebo", doors: [:left]) }
    let!(:island) { ResolvePermanent("Island", owner: p1) }
    let!(:their_forest) { ResolvePermanent("Forest", owner: p2) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before { game.tick! }

    def any_color_ability(land)
      land.activated_abilities.find { _1.class.name.include?("Greenhouse") }
    end

    it "gives lands you control a tap ability that adds one mana of any color" do
      expect(any_color_ability(island)).not_to be_nil
    end

    it "lets an Island produce red mana" do
      p1.activate_ability(ability: any_color_ability(island)) { |a| a.choose(:red) }

      expect(p1.mana_pool[:red]).to eq(1)
      expect(island).to be_tapped
    end

    it "does not give the ability to opponents' lands or to creatures" do
      expect(any_color_ability(their_forest)).to be_nil
      expect(any_color_ability(bears)).to be_nil
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:left)
      game.tick!

      expect(any_color_ability(island)).to be_nil
    end
  end

  context "Rickety Gazebo" do
    before { go_to_main_phase! }

    let(:room) { ResolvePermanent("Greenhouse Rickety Gazebo", doors: [:left]) }

    def unlock_gazebo
      p1.add_mana(green: 4)
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
      game.settle!
    end

    def stack_library(*names)
      names.reverse_each { p1.library.add(Card(_1, owner: p1)) }
    end

    it "mills four cards, then returns up to two permanent cards from among them" do
      stack_library("Opt", "Grizzly Bears", "Shock", "Island")
      unlock_gazebo

      choice = game.choices.first
      expect(choice).to be_a(Magic::Choice::ReturnFromAmong)
      expect(choice.choices.map(&:name)).to contain_exactly("Grizzly Bears", "Island")
      game.resolve_choice!(targets: choice.choices)

      expect(p1.hand.cards.map(&:name)).to include("Grizzly Bears", "Island")
      expect(p1.graveyard.cards.map(&:name)).to include("Opt", "Shock")
    end

    it "may return fewer than two" do
      stack_library("Opt", "Grizzly Bears", "Shock", "Island")
      unlock_gazebo

      bears = game.choices.first.choices.find { _1.name == "Grizzly Bears" }
      game.resolve_choice!(targets: [bears])

      expect(p1.hand.cards).to include(bears)
      expect(p1.graveyard.cards.map(&:name)).to include("Island")
    end

    it "cannot return three cards" do
      stack_library("Island", "Island", "Island", "Grizzly Bears")
      unlock_gazebo

      choice = game.choices.first
      expect { choice.resolve!(targets: choice.choices.first(3)) }.to raise_error(ArgumentError)
    end

    it "offers no choice when no permanent card is milled" do
      stack_library("Opt", "Shock", "Opt", "Shock")
      unlock_gazebo

      expect(game.choices).to be_empty
    end
  end
end
