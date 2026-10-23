module Magic
  module Cards
    class SorinRavenousNeonate < Planeswalker
      card_name "Sorin, Ravenous Neonate"
      type T::Super::Legendary, T::Planeswalker, "Sorin"
      color_indicator :white, :black
      loyalty 3

      # "+2: Create a Food token."
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 2
        def description = "Create a Food token."

        def resolve!
          create_token(token: Tokens::Food)
        end
      end

      # "-1: Sorin deals damage equal to the amount of life you gained this turn to any target."
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -1
        def description = "Sorin deals damage equal to the amount of life you gained this turn to any target."

        def target_choices = game.any_target

        def single_target? = true

        def resolve!(target:)
          damage = game.current_turn.life_gained_by_player(controller)
          deal_damage(damage, to: target) if damage.positive?
        end
      end

      # "-6: Gain control of target creature. It becomes a Vampire in addition to its other types. Put a lifelink counter
      # on it if you control a white permanent other than that creature or Sorin."
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -6
        def description = "Gain control of target creature. It becomes a Vampire in addition to its other types. Put a lifelink counter on it if you control a white permanent other than that creature or Sorin."

        def target_choices = battlefield.creatures

        def single_target? = true

        def resolve!(target:)
          target.controller = controller
          target.add_types(T::Creatures["Vampire"], until_eot: false)
          return unless battlefield.controlled_by(controller).any? { _1 != target && _1 != source && _1.colors.include?(:white) }

          add_counter Counters::Lifelink, to: target
        end
      end

      def event_handlers = { Events::SpellCast => TriggeredAbility::Extort }

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end

    class SorinOfHouseMarkov < Creature
      card_name "Sorin of House Markov"
      cost generic: 1, black: 1
      legendary_creature_type "Human Noble"
      power 1
      toughness 4
      keywords :lifelink
      back_face SorinRavenousNeonate

      # "At the beginning of each of your postcombat main phases, if you gained 3 or more life this turn, exile Sorin,
      # then return him to the battlefield transformed under his owner's control."
      class PostcombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller && life_gained_by(controller) >= 3

        def call = actor.exile_and_return_transformed!
      end

      def event_handlers = {
        Events::SpellCast => TriggeredAbility::Extort,
        Events::SecondMainPhase => PostcombatTrigger
      }
    end
  end
end
