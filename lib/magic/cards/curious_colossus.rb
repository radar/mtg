module Magic
  module Cards
    class CuriousColossus < Creature
      card_name "Curious Colossus"
      cost generic: 5, white: 2
      creature_type "Giant Warrior"
      power 7
      toughness 7

      class OpponentChoice < Magic::Choice::Targeted
        def choices = game.opponents(controller)

        def choice_amount = 1

        # "Each creature target opponent controls loses all abilities, becomes a Coward in addition to
        # its other types, and has base power and toughness 1/1." (No duration: it lasts.)
        def resolve!(target:)
          target.creatures.each do |creature|
            creature.lose_all_abilities!
            creature.add_types(T::Creatures["Coward"], until_eot: false)
            creature.modify_base_power(1, until_eot: false)
            creature.modify_base_toughness(1, until_eot: false)
            creature.apply_continuous_effects!
          end
        end
      end

      # "When this creature enters, each creature target opponent controls loses all abilities,
      # becomes a Coward in addition to its other types, and has base power and toughness 1/1."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(OpponentChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
