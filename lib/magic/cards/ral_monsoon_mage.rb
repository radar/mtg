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

      # "+1: Until your next turn, instant and sorcery spells you cast cost {1} less to cast." Ral remembers the turn
      # it was activated on; in a two player game the discount covers that turn and the opponent's turn after it.
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          granted = source.state[:discount_from]
          granted && source.game.current_turn.number < granted + 2 &&
            card.is_a?(Magic::Card) && (card.controller || card.owner) == source.controller &&
            (card.instant? || card.sorcery?)
        end
      end

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Until your next turn, instant and sorcery spells you cast cost {1} less to cast."

        def resolve!
          source.state[:discount_from] = game.current_turn.number
        end
      end

      # "-2: Ral deals 2 damage divided as you choose among one or two targets. Draw a card if you control a blue
      # permanent other than Ral." The division is answered when the ability resolves, like Mogg Mob.
      class DivideDamageChoice < Magic::Choice
        def choices = game.any_target.select { _1.can_be_targeted_by?(actor) }

        # Mandatory: skipping puts both points on the first legal target.
        def decline!
          resolve!(distribution: { choices.first => 2 })
        end

        def resolve!(distribution:)
          unless distribution.values.sum == 2 && distribution.values.all?(&:positive?)
            raise ArgumentError, "Ral must divide exactly 2 damage, at least 1 to each target"
          end
          raise ArgumentError, "illegal target" unless distribution.keys.all? { choices.include?(_1) }

          distribution.each { |target, damage| deal_damage(damage, to: target) }
          return unless game.battlefield.controlled_by(controller).any? { _1 != actor && _1.colors.include?(:blue) }

          controller.draw!
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -2
        def description = "Ral deals 2 damage divided as you choose among one or two targets. Draw a card if you control a blue permanent other than Ral."

        def resolve!
          game.choices.add(DivideDamageChoice.new(actor: source))
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
