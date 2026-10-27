# Build rules

The text between the lines is pasted, word for word, into the **How to build
it** section of every issue. It is also the test the plan itself must pass: an
issue, a dependency or a piece of an issue that breaks these rules is cut
from the plan.

---

Build only what the acceptance criteria and the tests above need. The
simplest code that makes them pass and keeps the architecture's interfaces is
the right code.

If the `ponytail` skill is available, work in ponytail's `full` mode for this
issue and finish your reply with what you skipped and any risk. Where ponytail
and this issue differ, this issue wins: in particular, write one test per
acceptance criterion at the level named under Tests required, not only one
small test per piece of logic.

- **YAGNI.** Write nothing for a later issue, a possible future need, or "in
  case". No option, setting, flag, hook, extension point, plugin interface,
  generic parameter or configuration that no requirement above asks for. If a
  requirement does not say it, it is not built; if it is wrong, that is a new
  issue.
- **Use what exists first.** Before adding a dependency, a helper or a
  wrapper, check whether the language, the standard library, the framework
  already chosen in **Stack to use**, or code already in the repository does
  it. Add a dependency only if it is in the stack decisions; any other is out
  of scope.
- **Follow the architecture exactly, and no further.** Build the modules,
  interfaces, ownership and flows as pasted above. Do not add a layer, a
  module, a seam, an adapter, a base class or an interface that the
  architecture does not name. A seam with one adapter stays a direct call.
- **Duplication is cheaper than the wrong abstraction.** Extract a shared
  piece only when the same logic exists in three places with the same reason
  to change. Until then, repeat it.
- **No speculative generality, no dead code.** Delete what this issue makes
  unused. Do not leave commented-out code, unused parameters, TODOs for work
  that is not in this issue, or flags that are always on.
- **Small, flat, readable.** Prefer plain functions and data to class
  hierarchies, plain control flow to clever tricks, and names from the
  glossary. Match the style of the code already in the repository.
- **Errors where the architecture says.** Handle the failures listed above,
  in the way listed. Do not catch, retry or log for failures no flow
  mentions.
- **Tests prove behaviour.** One test per acceptance criterion at the level
  named under Tests required, written first where practical. Test through the
  seams the architecture names, with real behaviour and a fake only for what
  the Tests section says to fake. Do not test the framework, add snapshot
  noise, or write a test with no way to fail.
- **Stay inside the issue.** Do not fix or refactor what this issue does not
  need, and do not build anything under **Out of scope**. Notice something
  else worth doing? Say so in the pull request; it does not go in this one.
- **Decide, do not ask.** Everything this issue needs is above. Where it is
  silent, take the simplest choice that serves the criteria, build it, and
  list it in the pull request under "Assumed".

---
