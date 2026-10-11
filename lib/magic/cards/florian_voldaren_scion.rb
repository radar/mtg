module Magic
  module Cards
    FlorianVoldarenScion = Creature("Florian, Voldaren Scion") do
      cost generic: 1, black: 1, red: 1
      legendary_creature_type "Vampire Noble"
      keywords :first_strike
      power 3
      toughness 3
    end

    class FlorianVoldarenScion < Creature
      class PickCardChoice < Magic::Choice::Targeted
        attr_reader :choices

        def initialize(actor:, cards:)
          @choices = cards
          super(actor: actor)
        end

        def prompt = "Exile one of the top #{choices.size} cards of your library. The rest go on the bottom in a random order. You may play the exiled card this turn."

        def choice_amount = 1

        def resolve!(target:)
          rest = choices - [target]
          target.exile!
          rest.each { |card| library.remove(card) }
          rest.shuffle.each { |card| library.add(card, library.count) }
          game.play_permissions.grant_until_end_of_turn(card: target, player: controller)
        end
      end

      # "At the beginning of each of your postcombat main phases, look at the top X cards of your library, where X is the
      # total amount of life your opponents lost this turn. Exile one of those cards and put the rest on the bottom of your
      # library in a random order. You may play the exiled card this turn."
      class PostcombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          cards = controller.library.take(controller.opponents_life_lost_this_turn)
          game.add_choice(PickCardChoice.new(actor: actor, cards: cards)) if cards.any?
        end
      end

      def event_handlers = { Events::SecondMainPhase => PostcombatTrigger }
    end
  end
end
