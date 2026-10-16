module Magic
  module Cards
    BirthingRitual = Enchantment("Birthing Ritual") do
      cost generic: 1, green: 1
    end

    class BirthingRitual < Enchantment
      # "Put the rest on the bottom of your library in a random order."
      module BottomsTheRest
        private

        def bottom(cards)
          cards.shuffle.each do |card|
            chooser.library.remove(card)
            chooser.library.push(card)
          end
        end
      end

      # "You may put a creature card with mana value X or less from among those cards onto the battlefield, where X is 1
      # plus the sacrificed creature's mana value." Declining (`game.skip_choice!`) puts every card on the bottom.
      class PutChoice < Magic::Choice
        include BottomsTheRest

        attr_reader :looked_at, :choices

        def initialize(actor:, looked_at:, max_mana_value:)
          super(actor: actor)
          @looked_at = looked_at
          @choices = looked_at.select { _1.creature? && _1.mana_value <= max_mana_value }
        end

        def resolve!(target: nil)
          raise ArgumentError, "#{target.name} is not a valid choice" if target && !choices.include?(target)

          if target
            Permanent.put_onto_battlefield(card: target, game: game, from_zone: target.zone, controller: chooser)
          end
          bottom(looked_at - [target])
        end

        def decline!
          resolve!
        end
      end

      # "Then you may sacrifice a creature." Declining (`game.skip_choice!`) puts every card on the bottom.
      class SacrificeChoice < Magic::Choice::May
        include BottomsTheRest

        attr_reader :looked_at

        def initialize(actor:, looked_at:)
          super(actor: actor)
          @looked_at = looked_at
        end

        def choices = battlefield.controlled_by(chooser).creatures

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          max_mana_value = target.mana_value + 1
          sacrifice target
          choice = PutChoice.new(actor: actor, looked_at: looked_at, max_mana_value: max_mana_value)
          choice.choices.empty? ? choice.resolve! : game.choices.add(choice)
        end

        def decline!
          bottom(looked_at)
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step? && controls_creature?

        def controls_creature? = battlefield.controlled_by(controller).creatures.any?

        def call
          return unless controls_creature?

          looked_at = controller.library.first(7)
          game.choices.add(SacrificeChoice.new(actor: actor, looked_at: looked_at))
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
