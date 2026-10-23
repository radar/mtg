module Magic
  # Resolves a copy of a spell or ability's effect directly, without going
  # through the stack or moving any card between zones -- a copy isn't a real
  # object, it just reproduces the resolution.
  module CopyEffect
    def self.resolve!(receiver, targets: [])
      resolver = receiver.method(:resolve!)
      pool = { target: targets.first, targets: targets }
      args = pool.select do |key, _|
        resolver.parameters.include?([:keyreq, key]) || resolver.parameters.include?([:key, key])
      end
      resolver.call(**args)
    end

    # Every way of copying a spell goes through here so "whenever you cast or copy" triggers (Magecraft) see each copy.
    def self.notify_copied!(game, spell:, player:, copies: 1)
      copies.times { game.notify!(Events::SpellCopied.new(spell: spell, player: player)) }
    end

    # Resolves `copies` copies of `receiver`, offering the "may choose new
    # targets" choice when it had targets to begin with; otherwise (no
    # targets, or nothing to retarget onto) just resolves the copies directly.
    #
    # `spell` is the spell card being copied, when the receiver is a spell (it is the receiver itself for a card). It is
    # what `Events::SpellCopied` carries; pass it when the receiver is a stand-in object (Grapeshot's storm copies).
    def self.resolve_with_choice!(actor:, receiver:, targets:, copies: 1, spell: (receiver if receiver.is_a?(Magic::Card)))
      copies += actor.game.battlefield.static_abilities.of_type(Abilities::Static::CopyMultiplier).sum(&:additional_copies)

      notify_copied!(actor.game, spell: spell, player: actor.controller, copies: copies) if spell

      if targets.any?
        actor.game.add_choice(Magic::Choice::MayCopyTargets.new(actor: actor, receiver: receiver, original_targets: targets, copies: copies))
      else
        copies.times { resolve!(receiver, targets: []) }
      end
    end
  end
end
