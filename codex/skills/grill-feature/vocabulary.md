# Vocabulary

From Matt Pocock's `codebase-design` skill (`mattpocock/skills`). Use these
words exactly; consistent language is the point.

**Module**: anything with an interface and an implementation, at any scale: a
function, a package, a slice across tiers. Not "component" or "service".

**Interface**: everything a caller must know to use the module correctly: the
types, but also invariants, ordering, error modes, required configuration,
and performance. Not "API" or "signature".

**Implementation**: what is inside the module.

**Depth**: the behaviour a caller or test gets per unit of interface they
must learn. A module is **deep** when a lot of behaviour sits behind a small
interface, **shallow** when the interface is nearly as complex as the
implementation. Shallow is the thing to avoid.

**Seam**: a place where behaviour can change without editing that place; the
location of a module's interface. Not "boundary" (overloaded with domain
boundaries).

**Adapter**: a concrete thing that satisfies an interface at a seam. It
describes a role, not what is inside.

**Leverage**: what callers get from depth. **Locality**: what maintainers get
from depth: change, bugs and knowledge concentrate in one place.

## Tests of a design

- **Deletion test.** Imagine deleting the module. If the complexity vanishes,
  it was a pass-through. If it reappears across N callers, it was earning its
  keep.
- **The interface is the test surface.** Callers and tests cross the same
  seam. If you must test past the interface, the module is the wrong shape.
- **One adapter is a hypothetical seam; two is a real one.** Add a seam only
  where something varies across it.
- **Accept dependencies, do not create them; return results, do not produce
  side effects; keep the surface small.** These make modules testable.
