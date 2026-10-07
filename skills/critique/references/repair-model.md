# The conversation and repair model — a UI is a dialogue that must repair misunderstandings

Frame: each user action is a **contribution**. The system must **ground** it (give evidence it was understood),
detect **breakdown**, and support **repair** that keeps the conversation alive instead of dropping it.
Sources: Clark & Brennan, "Grounding in communication" (1991); Schegloff, Jefferson & Sacks, "The preference
for self-correction" (1977); Norman's gulfs of execution and evaluation (Hutchins, Hollan & Norman 1986);
Grice's cooperative principle; Reeves & Nass, *The Media Equation*. URLs in `sources.md`.

## The walk-through, per task

Walk each key task through the two gulfs and ask the three questions at every step:

| Stage | Gulf | Question the critic asks | Broken when |
|---|---|---|---|
| Intention → action | execution | **Can the user tell what to do?** Is the next action discoverable, labelled with its outcome, within reach? | Hidden action, jargon label, no default, five equal choices |
| Action → result | — | **Can the user tell what happened?** Pressed state, progress, then the result stated in the user's words. | Dead button, silent save, generic "Success" |
| Result → goal | evaluation | **Can the user tell whether it worked, and undo or recover if not?** State visible, comparison with the goal easy, a way back. | No confirmation, state shown elsewhere, no undo, data lost on error |

Then induce one error per step (wrong format, empty, network off, back button, timeout, double click) and ask:
*Did the system say what it understood? Did it point at the trouble? Could I fix it myself without retyping?
Could I undo? Did the conversation survive?*

## Grounding → breakdown → repair

| Phase | Conversation analogue | UI obligation | Patterns that satisfy it |
|---|---|---|---|
| Grounding | acknowledgement, relevant next turn | Show you heard *and* understood: echo the parsed input; state the result in user terms. | Pressed state + specific success ("Moved 3 files to Archive"); positive inline validation |
| Pre-empting trouble | speaker designs the utterance for the listener | Constraints, defaults, format hints, rules stated up front. | Password / phone rules before typing; forgiving formats; good defaults |
| Breakdown detection | "Huh?" / "What?" (other-initiated repair) | Detect early and locally, not prematurely. | Validate after leaving a field, not on empty fields; clear the error as soon as it is fixed |
| Repair initiation | pointing at the trouble source | Message next to the source; says what and why; plain words; no blame. | NN/g error-message guidelines; Nielsen H9 |
| Self-repair | preference for self-correction | The **user** fixes it, in place, with their input **preserved**. | Form values kept on error; "did you mean…?"; editable summary |
| Reversal | "Sorry, I meant…" | Undo instead of interrogation for routine actions. | Undo toast; trash; versioning (Shneiderman S6) |
| Confirm with consequences | "Just to be sure: X, which means Y?" | Only for costly or irreversible actions; name the object and the effect; verb buttons; safe default; typed confirmation for severe. | NN/g confirmation dialogs; Apple HIG alerts |
| Pacing | one topic at a time | Essential first; advanced on request, ≤ 2 levels deep. | Progressive disclosure |
| Not dropping the conversation | resuming after an interruption | Timeout, crash, navigation, slow network must not destroy state. | Draft autosave; resumable checkout; warn before timeout; retry with the payload kept |
| Closure | "Great, done." | Explicit end + what happens next. | Confirmation screen with number and next step (S4) |
| Tone | politeness, cooperative principle | Copy obeys Grice: enough but not more, true, relevant, clear. People treat it as social (Media Equation). | No "invalid / illegal"; no false "almost done"; no nagging |

## How a finding is written from this model

Name the phase that broke, in the user's terms: "the form forgets everything on a wrong e-mail (self-repair broken:
input not preserved)", "Pay gives no sign for 3 s (grounding broken: no acknowledgement within 1 s)". The fix is
the pattern in the right-hand column, never "improve the UX".
