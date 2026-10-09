# CLAUDE.md

This is a personal learning fork of
[rohitg00/ai-engineering-from-scratch](https://github.com/rohitg00/ai-engineering-from-scratch).
The owner is working through the curriculum, not contributing lessons. The
contributor rules in `AGENTS.md` (one commit per lesson directory, dependency
allowlist, and so on) apply only when editing curriculum content for upstream.

## Learning mode

- `/start-learning` runs once and writes `LEARNING.md`. `/learn` teaches the
  next lesson and updates it. `/check-understanding <phase>` quizzes a phase.
- Lessons in a phase whose `LEARNING.md` status is `Review` are taught as an
  overview, per the owner's study approach. Cover what the concept is in plain
  words, why it matters for building agents and automation, one small example
  (run the lesson's code if it's quick), and the lesson quiz. Skip derivations,
  long exercises and from-scratch builds, and aim for 15-25 minutes per lesson.
  Log the note as `overview` so a later deep dive can find it. `Do` phases get
  the full lesson.
- Learner code (exercise solutions, experiments) goes under
  `learning-artifacts/phase-NN/MM-slug/` unless the lesson says otherwise.
  Don't overwrite the checked-in reference code in `phases/` with learner work.

## Git workflow (standing instructions from the owner)

Progress must never live only in the container. Cloud sessions are ephemeral,
and each one starts from `origin/main` on a fresh `claude/*` branch.

**Commit as you go.** Commit after each lesson, quiz or meaningful piece of
code. Keep progress and code in separate commits, using these subjects (max 72
characters):

| Change | Subject |
|--------|---------|
| `LEARNING.md` or other progress files | `progress(phase-NN/MM): complete <slug>, quiz 5/6` |
| Learner code or experiments | `practice(phase-NN/MM): <what was built>` |
| Notes, cheat sheets | `notes(phase-NN): <topic>` |
| Repo or tooling setup | `chore(setup): <change>` |
| Upstream sync | the default merge message |

The commit body says what was learned or what was hard, in one or two lines.

**End of session.** Push the session branch, then fast-forward `main` to it
and push `main`. The owner has given standing permission for this, so the
next session starts with all progress:

```bash
git push -u origin HEAD
git fetch origin main
git checkout main && git merge --ff-only origin/main && git merge --ff-only -
git push origin main
git checkout -
```

If `--ff-only` fails because `main` moved, merge `origin/main` into the session
branch first, push it, then retry.

**Syncing with upstream.** The SessionStart hook re-adds the `upstream` remote
and reports whether `main` is behind. Sync when the owner asks or when it's
behind at session start:

```bash
git checkout main && git merge --ff-only origin/main
git merge upstream/main          # use a merge, never rebase or force-push
git push origin main
git checkout - && git merge main
```

Conflicts can occur only in files the learner also changed. Keep the learner's
version of `LEARNING.md` and `learning-artifacts/`, and keep upstream's version
of lesson content.
