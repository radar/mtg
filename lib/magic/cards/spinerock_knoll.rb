module Magic
  module Cards
    SpinerockKnoll = Card("Spinerock Knoll") do
      type "Land"
      enters_tapped
    end

    class SpinerockKnoll < Card
      # Hideaway 4: look at the top four cards, exile one face down, put the rest on the bottom in a random order.
      class HideawayChoice < Magic::Choice::Targeted
        attr_reader :choices

        def prompt = "Hideaway 4: exile one of the top four cards of your library face down. The rest go on the bottom in a random order."

        def initialize(actor:, cards:)
          @choices = cards
          super(actor: actor)
        end

        def choice_amount = 1

        def resolve!(target:)
          rest = choices - [target]
          target.exile!
          actor.exiled_cards << target
          rest.each { |card| library.remove(card) }
          rest.shuffle.each { |card| library.add(card, library.count) }
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          cards = controller.library.take(4)
          game.choices.add(HideawayChoice.new(actor: actor, cards: cards)) if cards.any?
        end
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      # "{R}, {T}: You may play the exiled card without paying its mana cost if an opponent was dealt 7 or more damage this
      # turn." The exiled card may then be cast or played for free this turn.
      class PlayExiledCardAbility < Magic::ActivatedAbility
        costs "{R}, {T}"

        def requirements_met?
          source.exiled_cards.any? { _1.zone&.exile? } && opponent_dealt_seven?
        end

        def resolve!
          source.exiled_cards.select { _1.zone&.exile? }.each do |card|
            game.play_permissions.grant_until_end_of_turn(card: card, player: controller, free: true)
          end
        end

        private

        def opponent_dealt_seven?
          game.opponents(controller).any? do |opponent|
            game.current_turn.events.select { _1.is_a?(Events::DamageDealt) && _1.target == opponent }.sum(&:damage) >= 7
          end
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [ManaAbility, PlayExiledCardAbility]
    end
  end
end
