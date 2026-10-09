module Magic
  module Cards
    TheNotaryHobbits = Creature("The Notary Hobbits") do
      cost generic: 3, green: 2
      legendary_creature_type "Halfling Advisor"
      power 1
      toughness 1
    end

    class TheNotaryHobbits < Creature
      # "When The Notary Hobbits enter, if they're not a token, create two tokens that are copies of them, except the
      # tokens aren't legendary."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          !actor.token?
        end

        def call
          2.times do
            copy = Permanent.resolve(game: game, owner: controller, card: actor.copiable_card, token: true, copy: true, cast: false)
            copy.remove_types(T::Super::Legendary, until_eot: false)
            copy.apply_continuous_effects!
          end
        end
      end

      def etb_triggers = [EntersTrigger]

      # "{T}: Add {C} for each Halfling you control."
      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(colorless: source.controller.permanents.count { _1.type?("Halfling") })
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
