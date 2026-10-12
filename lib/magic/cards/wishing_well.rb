module Magic
  module Cards
    class WishingWell < Artifact
      card_name "Wishing Well"
      cost generic: 3, blue: 1

      # {T}: Put a coin counter on this artifact. When you do, you may cast target instant or sorcery card with
      # mana value equal to the number of coin counters on this artifact from your graveyard without paying its
      # mana cost. If that spell would be put into your graveyard, exile it instead. Activate only as a sorcery.
      class CoinAbility < Magic::ActivatedAbility
        costs "{T}"
        activate_only_as_sorcery

        class CastChoice < Magic::Choice::Targeted
          def initialize(actor:, value:)
            @value = value
            super(actor: actor)
          end

          def choices = controller.graveyard.select { (_1.instant? || _1.sorcery?) && _1.mana_value == @value }

          def choice_amount = 1

          def resolve!(target:)
            Magic::Choice::FreeCast.start(actor: actor, card: target)
          end
        end

        def resolve!
          trigger_effect(:add_counter, counter_type: "coin", target: source, amount: 1)
          value = source.counters.of_type(Counters["coin"]).count
          choice = CastChoice.new(actor: source, value: value)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def activated_abilities = [CoinAbility]
    end
  end
end
