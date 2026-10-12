module Magic
  module Cards
    class KaitoBaneOfNightmares < Planeswalker
      card_name "Kaito, Bane of Nightmares"
      type T::Super::Legendary, T::Planeswalker, "Kaito"
      cost generic: 2, blue: 1, black: 1
      ninjutsu Costs::Mana.new(generic: 1, blue: 1, black: 1)
      loyalty 4

      # "During your turn, as long as Kaito has one or more loyalty counters on him, he's a 3/4 Ninja creature and has
      # hexproof." Three static abilities share the condition.
      module DuringYourTurn
        def self.included(base)
          base.conditions { source.controller == game.current_turn.active_player && source.loyalty.positive? }
          base.applicable_targets { [source] }
        end
      end

      class NinjaCreature < Abilities::Static::TypeGrant
        include DuringYourTurn
        type_grants T::Creature, T::Creatures["Ninja"]
      end

      class NinjaStats < Abilities::Static::CharacteristicSetting
        include DuringYourTurn
        sets_base_power_and_toughness 3, 4
      end

      class NinjaHexproof < Abilities::Static::KeywordGrant
        include DuringYourTurn
        keyword_grants Keywords::HEXPROOF
      end

      # "Ninjas you control get +1/+1."
      class NinjaEmblem < Magic::Emblem
        class Buff < Abilities::Static::PowerAndToughnessModification
          modify power: 1, toughness: 1

          def applicable_targets = source.controller.creatures.by_type("Ninja")
        end

        def static_abilities = [Buff]
      end

      # "+1: You get an emblem with 'Ninjas you control get +1/+1.'"
      class PlusOneAbility < LoyaltyAbility
        def loyalty_change = 1
        def description = "You get an emblem with \"Ninjas you control get +1/+1.\""

        def resolve!
          game.add_emblem(NinjaEmblem.new(game: game, owner: controller))
        end
      end

      # "0: Surveil 2. Then draw a card for each opponent who lost life this turn."
      class ZeroAbility < LoyaltyAbility
        def loyalty_change = 0
        def description = "Surveil 2. Then draw a card for each opponent who lost life this turn."

        # Draws once the surveil has been answered.
        class SurveilThenDraw < Magic::Choice::Surveil
          def resolve!(**args)
            super
            opponents = game.opponents(chooser)
            lost = opponents.count { |opponent| game.current_turn.events.any? { _1.is_a?(Events::LifeLoss) && _1.player == opponent } }
            lost.times { chooser.draw! }
          end
        end

        def resolve!
          game.choices.add(SurveilThenDraw.new(actor: source, amount: 2))
        end
      end

      # "-2: Tap target creature. Put two stun counters on it."
      class MinusTwoAbility < LoyaltyAbility
        def loyalty_change = -2
        def description = "Tap target creature. Put two stun counters on it."

        def target_choices = battlefield.creatures

        def resolve!(target:)
          trigger_effect(:tap, target: target)
          trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 2)
        end
      end

      def static_abilities = [NinjaCreature, NinjaStats, NinjaHexproof]
      def loyalty_abilities = [PlusOneAbility, ZeroAbility, MinusTwoAbility]
    end
  end
end
