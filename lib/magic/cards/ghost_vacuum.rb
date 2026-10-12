module Magic
  module Cards
    GhostVacuum = Artifact("Ghost Vacuum") do
      cost generic: 1
    end

    class GhostVacuum < Artifact
      # The cards this artifact has exiled; it stays readable after the artifact is sacrificed.
      def exiled_cards = (@exiled_cards ||= [])

      # "{T}: Exile target card from a graveyard."
      class ExileAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          game.players.flat_map { _1.graveyard.cards }
        end

        def resolve!(target:)
          target.exile!
          source.exiled_cards << target
        end
      end

      # "{6}, {T}, Sacrifice this artifact: Put each creature card exiled with this artifact onto the battlefield under
      # your control with a flying counter on it. Each of them is a 1/1 Spirit in addition to its other types. Activate
      # only as a sorcery."
      class ReleaseAbility < Magic::ActivatedAbility
        costs "{6}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def resolve!
          source.exiled_cards.select { _1.creature? && _1.zone&.exile? }.each do |card|
            permanent = card.resolve!(controller: controller)
            add_counter("flying", to: permanent)
            permanent.add_types("Spirit", until_eot: false)
            permanent.modify_base_power(1, until_eot: false)
            permanent.modify_base_toughness(1, until_eot: false)
          end
        end
      end

      def activated_abilities = [ExileAbility, ReleaseAbility]
    end
  end
end
