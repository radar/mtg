# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RadagastTheBrown do
  include_context "two player game"

  before { go_to_main_phase! }

  def stack_library(*names)
    names.reverse_each { p1.library.add(Card(_1)) }
  end

  def radagast = @radagast ||= ResolvePermanent("Radagast the Brown".gsub(" the ", " The "), owner: p1)

  let(:choice) { game.choices.first }

  it "is a 2/5 legendary Avatar Wizard" do
    stack_library("Forest")
    expect(radagast.power).to eq(2)
    expect(radagast.toughness).to eq(5)
    expect(radagast).to be_legendary
    expect(radagast.type?("Avatar")).to eq(true)
    expect(radagast.type?("Wizard")).to eq(true)
  end

  context "when Radagast enters" do
    before do
      stack_library("Forest", "Gandalf Goblins Bane", "Serra Angel", "Grizzly Bears", "Island")
      radagast
    end

    it "looks at the top X cards where X is Radagast's mana value" do
      expect(choice).to be_a(described_class::LookChoice)
      expect(choice.looked_at.map(&:name)).to eq(["Forest", "Gandalf, Goblins' Bane", "Serra Angel", "Grizzly Bears"])
    end

    it "offers only creature cards that share no creature type with a creature you control" do
      expect(choice.choices.map(&:name)).to contain_exactly("Serra Angel", "Grizzly Bears")
    end

    it "puts the chosen card into hand and the rest on the bottom" do
      angel = choice.choices.find { _1.name == "Serra Angel" }
      game.resolve_choice!(target: angel)

      expect(p1.hand.cards).to include(angel)
      expect(p1.library.first.name).to eq("Island")
      expect(p1.library.last(3).map(&:name)).to contain_exactly("Forest", "Gandalf, Goblins' Bane", "Grizzly Bears")
    end

    it "rejects a creature card sharing a type with a creature you control" do
      gandalf = choice.looked_at.find { _1.name == "Gandalf, Goblins' Bane" }

      expect(gandalf).not_to be_nil
      expect { game.resolve_choice!(target: gandalf) }.to raise_error(ArgumentError)
    end

    it "may decline, putting everything looked at on the bottom" do
      count = p1.library.count
      game.skip_choice!

      expect(p1.library.count).to eq(count)
      expect(p1.library.first.name).to eq("Island")
      expect(p1.library.last(4).map(&:name)).to contain_exactly("Forest", "Gandalf, Goblins' Bane", "Serra Angel", "Grizzly Bears")
    end
  end

  context "when another creature enters" do
    before do
      stack_library("Forest")
      radagast
      game.skip_choice!
    end

    it "looks at X cards for that creature's mana value and excludes shared types" do
      stack_library("Serra Angel", "Grizzly Bears", "Island")
      ResolvePermanent("Grizzly Bears", owner: p1)

      expect(choice.looked_at.map(&:name)).to eq(["Serra Angel", "Grizzly Bears"])
      expect(choice.choices.map(&:name)).to eq(["Serra Angel"])
    end

    it "does not trigger for a creature token" do
      stack_library("Serra Angel", "Grizzly Bears", "Island")
      count = p1.library.count
      ResolvePermanent("Grizzly Bears", owner: p1, token: true)

      expect(game.choices).to be_empty
      expect(p1.library.count).to eq(count)
    end

    it "does not trigger for a creature an opponent controls" do
      stack_library("Serra Angel", "Grizzly Bears", "Island")
      count = p1.library.count
      ResolvePermanent("Grizzly Bears", owner: p2)

      expect(game.choices).to be_empty
      expect(p1.library.count).to eq(count)
    end

    it "does not trigger for a noncreature permanent" do
      stack_library("Serra Angel", "Grizzly Bears", "Island")
      ResolvePermanent("Sol Ring", owner: p1)

      expect(game.choices).to be_empty
    end
  end
end
