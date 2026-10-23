module Magic
  module Cards
    class RalLeylineProdigy < Planeswalker
      card_name "Ral, Leyline Prodigy"
      type T::Super::Legendary, T::Planeswalker, "Ral"
      color_indicator :blue, :red
      loyalty 2

      # "Ral enters with an additional loyalty counter on him for each instant and sorcery spell you've cast this
      # turn."
      def extra_entering_loyalty(permanent)
        permanent.game.current_turn.spells_cast.count do |cast|
          cast.player == permanent.controller && (cast.spell.instant? || cast.spell.sorcery?)
        end
      end

      # "+1: Until your next turn, instant and sorcery spells you cast cost {1} less to cast." Ral flags the discount
      # with `remember_until_turn_of!`, which clears it as his controller's next upkeep begins.
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          source.state[:discounting] &&
            card.is_a?(Magic::Card) && (card.controller || card.owner) == source.controller &&
            (card.instant? || card.sorcery?)
        end
      end

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Until your next turn, instant and sorcery spells you cast cost {1} less to cast."

        def resolve!
          source.remember_until_turn_of!(:discounting, controller)
        end
      end

      # "-2: Ral deals 2 damage divided as you choose among one or two targets. Draw a card if you control a blue
      # permanent other than Ral." Targets and the division are chosen on activation, as with any divided damage:
      # `a.targeting(p2, bears, distribution: { p2 => 1, bears => 1 })`; one target takes both points. See
      # `Actions::ActivateLoyaltyAbility#targeting`.
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -2
        def description = "Ral deals 2 damage divided as you choose among one or two targets. Draw a card if you control a blue permanent other than Ral."

        def target_choices = game.any_target

        def divided_amount = 2

        def max_divided_targets = 2

        # A target that left the battlefield is skipped; the rest still take their damage.
        def resolve!(distribution:)
          distribution.each do |target, damage|
            next if target.is_a?(Permanent) && target.zone.nil?

            deal_damage(damage, to: target)
          end
          return unless game.battlefield.controlled_by(controller).any? { _1 != source && _1.colors.include?(:blue) }

          controller.draw!
        end
      end

      # "-8: Exile the top eight cards of your library. You may cast instant and sorcery spells from among them this
      # turn without paying their mana costs."
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -8
        def description = "Exile the top eight cards of your library. You may cast instant and sorcery spells from among them this turn without paying their mana costs."

        def resolve!
          [8, controller.library.count].min.times do
            card = controller.library.first
            exile_target(card)
            next unless card.instant? || card.sorcery?

            game.play_permissions.grant_until_end_of_turn(card:, player: controller, free: true)
          end
        end
      end

      def static_abilities = [CostReduction]

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end

    class RalMonsoonMage < Creature
      card_name "Ral, Monsoon Mage"
      cost generic: 1, red: 1
      legendary_creature_type "Human Wizard"
      power 1
      toughness 3
      back_face RalLeylineProdigy

      # "Instant and sorcery spells you cast cost {1} less to cast."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          card.is_a?(Magic::Card) && (card.controller || card.owner) == source.controller && (card.instant? || card.sorcery?)
        end
      end

      class FlipChoice < Magic::Choice::May
        def prompt = "Exile Ral, then return him transformed?"

        def resolve! = actor.exile_and_return_transformed!
      end

      # "Whenever you cast an instant or sorcery spell during your turn, flip a coin. If you lose the flip, Ral deals
      # 1 damage to you. If you win the flip, you may exile Ral. If you do, return him to the battlefield
      # transformed under his owner's control."
      class FlipTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && game.current_turn.active_player == controller && (spell.instant? || spell.sorcery?)
        end

        def call
          if controller.flip_coin!
            game.choices.add(FlipChoice.new(actor:))
          else
            deal_damage(1, to: controller)
          end
        end
      end

      def static_abilities = [CostReduction]

      def event_handlers = { Events::SpellCast => FlipTrigger }
    end
  end
end
