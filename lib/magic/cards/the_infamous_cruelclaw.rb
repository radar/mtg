module Magic
  module Cards
    TheInfamousCruelclaw = Creature("The Infamous Cruelclaw") do
      legendary_creature_type "Weasel Mercenary"
      cost generic: 1, black: 1, red: 1
      keywords :menace
      power 3
      toughness 3
    end

    class TheInfamousCruelclaw < Creature
      # Whenever The Infamous Cruelclaw deals combat damage to a player, exile cards from the top of your library
      # until you exile a nonland card. You may cast that card by discarding a card rather than paying its mana
      # cost.
      class DamageTrigger < TriggeredAbility
        # The controller picks the target of the free cast.
        class TargetChoice < Magic::Choice::Targeted
          def initialize(actor:, action:)
            super(actor: actor)
            @action = action
          end

          def prompt = "Choose a target for #{@action.card.name}."

          def choices = @action.target_choices.to_a

          def choice_amount = 1

          def decline!
            resolve!(target: choices.first)
          end

          def resolve!(target:)
            @action.targeting(target)
            game.take_action(@action)
          end
        end

        class DiscardChoice < Magic::Choice::Discard
          def initialize(actor:, player:, card:)
            super(actor: actor, player: player)
            @card = card
          end

          def resolve!(card:)
            super
            action = controller.prepare_cast(card: @card, by_effect: true)
            action.mana_cost = {}
            single_target = @card.respond_to?(:target_choices) && !(@card.respond_to?(:multi_target?) && @card.multi_target?)
            if single_target && action.target_choices.any?
              game.add_choice(TargetChoice.new(actor: actor, action: action))
            else
              game.take_action(action)
            end
          end
        end

        class MayCast < Magic::Choice::May
          def initialize(actor:, card:)
            @card = card
            super(actor: actor)
          end

          def resolve!
            game.choices.add(DiscardChoice.new(actor: actor, player: controller, card: @card)) if controller.hand.any?
          end
        end

        def should_perform? = event.source == actor && event.target.is_a?(Player)

        def call
          exiled = nil
          while (card = controller.library.first)
            exile_target(card)
            unless card.land?
              exiled = card
              break
            end
          end
          game.choices.add(MayCast.new(actor: actor, card: exiled)) if exiled
        end
      end

      def event_handlers = super.merge(Events::CombatDamageDealt => DamageTrigger)
    end
  end
end
