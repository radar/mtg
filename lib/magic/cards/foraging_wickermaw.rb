module Magic
  module Cards
    ForagingWickermaw = Creature("Foraging Wickermaw") do
      cost generic: 2
      artifact_creature_type("Scarecrow")
      power 1
      toughness 3
    end

    class ForagingWickermaw < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]

      # "{1}: Add one mana of any color. This creature becomes that color until end of
      # turn. Activate only once each turn."
      class ManaAbility < Magic::ManaAbility
        choices :all
        costs "{1}"
        once_each_turn

        def resolve!
          super
          source.change_colors!([choice])
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
