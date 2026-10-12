module Magic
  module Cards
    GandalfWanderingWizard = Creature("Gandalf, Wandering Wizard") do
      cost generic: 4, blue: 1
      legendary_creature_type("Avatar Wizard")
      ward generic: 3
      power 4
      toughness 5
    end

    class GandalfWanderingWizard < Creature
      # "{6}: Gandalf's owner shuffles him into their library and draws three cards."
      class ShuffleAbility < Magic::ActivatedAbility
        costs "{6}"

        def resolve!
          owner = source.owner
          game.add_effect(Effects::ShuffleIntoLibrary.new(source: source, target: source))
          trigger_effect(:draw_cards, player: owner, number_to_draw: 3)
        end
      end

      def activated_abilities = [ShuffleAbility]
    end
  end
end
