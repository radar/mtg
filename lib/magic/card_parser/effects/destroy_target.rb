# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Destroy target creature." / "Destroy target artifact."
      class DestroyTarget < Data.define(:kind)
        include Effect

        LINE = /\ADestroy target (?<kind>creature|artifact|enchantment|land)\.?\z/i
        COLLECTIONS = { "creature" => "creatures", "artifact" => "artifacts", "enchantment" => "enchantments", "land" => "lands" }.freeze

        def self.parse(text)
          new(kind: $~[:kind].downcase) if LINE.match(text)
        end

        def target_choices = "battlefield.#{COLLECTIONS.fetch(kind)}"
        def resolve_call = "trigger_effect(:destroy_target, target: target)"
      end
    end
  end
end
