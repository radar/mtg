module Magic
  module Cards
    class BreOfClanStoutarm < Creature
      card_name "Bre of Clan Stoutarm"
      cost generic: 2, red: 1, white: 1
      legendary_creature_type "Giant Warrior"
      power 4
      toughness 4

      # "{1}{W}, {T}: Another target creature you control gains flying and lifelink until end of turn."
      class GrantAbility < Magic::ActivatedAbility
        costs "{1}{W}, {T}"

        def target_choices = controller.creatures.except(source)

        def resolve!(target:)
          trigger_effect(:grant_keyword, target:, keyword: :flying)
          trigger_effect(:grant_keyword, target:, keyword: :lifelink)
        end
      end

      # You may cast the exiled card for free when its mana value is at most the life gained;
      # declining (or a card that costs too much) puts it into your hand instead.
      class CastOrHandChoice < Magic::Choice::May
        attr_reader :card

        def initialize(actor:, card:)
          super(actor:)
          @card = card
        end

        def resolve!
          controller.cast(card:, by_effect: true) { _1.mana_cost = 0 }
        end

        def decline! = card.move_to_hand!(controller)
      end

      # "At the beginning of your end step, if you gained life this turn, exile cards from the top of
      # your library until you exile a nonland card. You may cast that card without paying its mana
      # cost if the spell's mana value is less than or equal to the amount of life you gained this
      # turn. Otherwise, put it into your hand."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && life_gained_by(controller).positive?
        end

        def call
          card = nil
          while (top = controller.library.first)
            trigger_effect(:exile, target: top)
            next if top.land?

            card = top
            break
          end
          return unless card

          if card.mana_value <= life_gained_by(controller)
            game.choices.add(CastOrHandChoice.new(actor:, card:))
          else
            card.move_to_hand!(controller)
          end
        end
      end

      def activated_abilities = [GrantAbility]

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
