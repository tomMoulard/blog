---
title: "Teaching an AI to Teach an AI: The CodeRabbit Review Agent Meta-Saga"
author: Tom Moulard
categories: ["AI", "Developer Tools", "Code Quality", "Automation"]
date: 2026-03-12T00:00:00.000+02:00
draft: false
tags: ["ai", "code-review", "automation", "coderabbit", "opencode", "ai-agents", "developer-tools", "code-quality", "meta-programming", "claude", "subagents"]
type: "post"
url: "/coderabbit-review-agent-in-opencode"
---

I built an AI agent whose entire job is to babysit another AI that reviews my code.

Yeah, I know how that sounds. Like we're two levels deep into AI inception and I've lost the plot. But hear me out—this actually solved a real problem I was having, and the solution is honestly kind of hilarious.

## The Problem: CodeRabbit is Slow as Hell

So I'm using [OpenCode](https://github.com/anomalyco/opencode) (LLM-powered coding assistant, it's great) and I wanted automated code reviews. I already had [CodeRabbit](https://coderabbit.ai) set up because who doesn't want an AI nitpicking your code at 3am?

The problem: CodeRabbit takes 20-30 minutes per review. Then it spits out this massive markdown file—critical bugs mixed with "you should use const instead of let" style suggestions, zero prioritization, just raw dump of everything wrong with your life choices.

I got tired of manually parsing these reports around the third time I did it in January. So I spent a weekend building **@cr**—a subagent that sits in OpenCode and does the whole dance: run review, wait forever, parse output, apply fixes, run again until clean.

It's an AI managing another AI. Meta? Yes. Stupid? Maybe. Does it work? Surprisingly well.

## What @cr Actually Does

The agent basically acts as a project manager who never gets tired:

- Runs CodeRabbit on uncommitted changes (or specific files, or branches—whatever you want)
- Saves output to timestamped files because Claude's context window isn't infinite
- Parses and sorts findings: Critical → Important → "please consider using const"
- Applies fixes automatically using OpenCode's Edit tool
- Re-runs the review up to 3 times or until everything's clean
- Tells you honestly what worked and what's still broken

Honestly? It's like having a code reviewer who doesn't get annoyed when you ask them to review the same diff three times. Which, if you've ever been that reviewer, you know is valuable.

## How It Actually Works (The Interesting Parts)

### Figuring Out What to Review

First it checks `git status` to see if you have uncommitted changes. If yes, review those. If not, compare current branch against main.

You can be specific too:
- `@cr` - reviews whatever's uncommitted
- `@cr agent/cr.md` - just that file
- `@cr review against develop` - compare against different branch

Pretty straightforward.

### Running CodeRabbit (aka Waiting Forever)

This is the boring part:

```bash
coderabbit review --plain -t uncommitted 2>&1 | \
  tee /tmp/coderabbit-$(date +%Y%m%d-%H%M%S).md
```

The `--plain` flag stops CodeRabbit from using fancy formatting that breaks parsing. The `tee` saves output to a timestamped file like `/tmp/coderabbit-20260312-095530.md` while still showing you what's happening.

Then the agent polls every 2 minutes to check if CodeRabbit finished. I tried every 30 seconds initially but that felt like overkill. Even 2 minutes feels aggressive when you're staring at your terminal.

### Parsing the Output

CodeRabbit spits out something like:

```markdown
**Critical**: Potential SQL injection in user input handler (line 42)
**Important**: Missing error handling for database connection
**Suggestion**: Consider using const instead of let here
```

The agent reads the entire file (yes, even the parts that don't fit in context) and sorts by severity:

- **Critical/Security** - will definitely break things or get you hacked
- **Important** - actual bugs, performance problems
- **Nits** - style preferences, minor stuff

### Applying Fixes

This is where it gets interesting. For each issue:

1. Read the file to understand what's going on
2. Apply fix using OpenCode's Edit tool
3. Try not to break everything else in the process
4. Match existing code style (I don't want the agent reformatting my entire codebase)

By default it fixes **everything**, not just critical issues. If I'm running a code review, I want it done properly. Half-assing automation is worse than not automating at all.

### The Iteration Loop

After fixes are applied, run CodeRabbit again. Same command, different timestamp:

```bash
coderabbit review --plain -t uncommitted 2>&1 | \
  tee /tmp/coderabbit-20260312-095530-iter2.md
```

Compare new findings with previous:
- Issues got fixed? Good.
- New issues appeared? Fix those.
- Same issues still there? Try once more.
- Still broken after 3 tries? Give up and tell the human.

The 3-iteration limit is important. I learned this the hard way after watching it loop 7 times trying to fix the same issue in February. After 3 attempts, it's probably a problem that needs actual human judgment.

### What You Get at the End

```
CodeRabbit Review Complete

Iterations: 2 of 3

Issues Found (Iteration 1):
- 3 Critical
- 7 Important
- 12 Suggestions

Issues Fixed:
- Fixed SQL injection vulnerability in auth handler
- Added error handling for all database operations
- Refactored 15 style inconsistencies

Final Status:
- 0 Critical remaining
- 0 Important remaining
- 2 Suggestions remaining (minor formatting preferences)
```

Clear, honest, done.

## The Annoying Problems I Had to Solve

Building this thing was more interesting than I expected. A few things that came up:

### Context Windows Are Not Infinite

CodeRabbit outputs can be huge. Like, way bigger than Claude's context window. I found this out when reviewing a large refactor in early February and the agent just... forgot what it was doing halfway through.

Solution: save everything to timestamped files:

```bash
/tmp/coderabbit-20260312-095530.md        # Iteration 1
/tmp/coderabbit-20260312-095730-iter2.md  # Iteration 2
/tmp/coderabbit-20260312-095930-iter3.md  # Iteration 3
```

The agent reads from these files as needed instead of trying to keep everything in memory. Simple fix, should've done it from the start.

### Don't Create Infinite Loops

Without limits, the agent could review-fix-review-fix forever. So:

- Max 3 iterations (after that, it's a human problem)
- Detect if the same issue keeps appearing (probably can't fix it automatically)
- 30-minute timeout per CodeRabbit run (it's never actually needed this long, but just in case)

### Reviewing Specific Files Without Breaking Git

Sometimes you want to review just one file: `@cr agent/cr.md`

CodeRabbit doesn't have a "review only this file" option. First idea: use `git stash` to hide other changes.

**Terrible idea.** That's how you lose work and ruin someone's day.

Better solution:
1. Run CodeRabbit on everything (read-only, safe)
2. Parse output and filter for the file you care about
3. Only apply fixes to that file
4. Report: "Reviewed agent/cr.md. Other files untouched."

No git manipulation. No lost changes. Much better.

## Things I Learned Building This

**Agents should do one thing well.** The @cr agent orchestrates CodeRabbit reviews. That's it. It doesn't write code, doesn't design systems, doesn't make architectural decisions. This narrow focus is why it actually works reliably.

**External storage is your friend.** AI memory is just files. Save everything because you will need it later when the context window fills up.

**Iteration limits matter.** The 3-try maximum prevents infinite loops but gives enough room to actually fix things. After 3 attempts, involve a human.

**Never manipulate git state.** The agent uses `git status`, `git diff`, `git log`—all read-only. It never touches `git stash`, `git reset`, or `git checkout`. I value my sanity.

**Be honest when things fail.** When @cr hits the iteration limit:

```
Reached maximum iteration limit. Some issues may require manual review.

Remaining issues:
- Complex refactoring needed in auth system (line 142)
- Architectural decision required for API versioning
```

No pretending it worked perfectly. Just the truth.

## Does It Actually Save Time?

My workflow before:
1. Write code
2. Run CodeRabbit manually
3. Wait 20-30 minutes
4. Read through findings
5. Fix things one by one
6. Run again to verify
7. Total: 2-3 hours for a thorough review cycle

Now:
1. Write code
2. Type `@cr`
3. Make coffee, check email, contemplate life choices
4. Come back to mostly-fixed code
5. Total: 30-45 minutes (mostly CodeRabbit being slow)

It's not perfect. Complex architectural issues still need me. But for 90% of code review stuff—null checks, error handling, style consistency—it just handles it.

## What's Next

I could build @cr-watcher to monitor @cr's performance. Or @meta-review to review the reviews. At some point we need to stop before creating an AI singularity though.

The real takeaway is that specialized subagents work well. Each does one thing. You chain them together and suddenly your workflow feels like having a small team.

## Try It if You Want

The agent is [open source](https://github.com/tomMoulard/configLoader/blob/main/opencode/agent/cr.md). If you want to use it:

1. Install [CodeRabbit CLI](https://docs.coderabbit.ai)
2. Install [OpenCode](https://github.com/anomalyco/opencode)
3. Copy cr.md to your `~/.config/opencode/agent/` directory
4. Run `@cr`

Warning: watching an AI manage another AI is weirdly entertaining. I run it more often than I probably should.

## Final Thoughts

We're at a point where:
- AIs write code
- Other AIs review it
- Other AIs manage those reviews
- Humans drink coffee and occasionally make decisions

Is this what I imagined when I started programming? Not even close. Is it useful? Yeah, actually.

The @cr agent is just one example of specialized subagents. Each handles one specific job. Chain enough of them together and you have something that starts to feel like a development team that never sleeps and doesn't complain about meetings.

Which leaves humans free to work on the actually interesting problems. Like figuring out if we really need another JavaScript framework this week.

(We don't. But someone will build it anyway. And @cr will review it.)

---

**Note:** Yes, I used AI to help draft parts of this post. Given the topic, hiding that would be ridiculous. I edited it heavily though because AI-generated blog posts have a very specific smell to them, and I didn't want this to read like a ChatGPT essay.

Shout out to the [OpenCode](https://github.com/anomalyco/opencode) and [CodeRabbit](https://coderabbit.ai) teams for building tools that are actually useful instead of just hype. This agent only exists because both tools work well enough to be worth automating.
