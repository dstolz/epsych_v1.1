# eval_adaptive_training_mode

`gui.eval_adaptive_training_mode` enables or disables per-parameter adaptive training from a GUI toggle callback.

It is typically used by parameter-control widgets that need to temporarily suspend randomisation and let trial outcomes drive a single `hw.Parameter` through a `gui.AdaptiveTraining` window.

## Wiring it to a state button or to a parameter

Either a state `uibutton`'s `ValueChangedFcn` or the `PostUpdateFcn` of a `gui.components.Parameter_Control` checkbox works — both receive an `event` carrying `.Value`.

Prefer the checkbox. A state button's state lives only in the widget, so nothing records it and a saved phase cannot restore it; a checkbox bound to a Boolean `hw.Parameter` marked `PersistWithPhase` makes the training state part of the stage's configuration (see `documentation/hw/hw_Parameter.md`). `cl_AppetitiveDetection_BehaviorGUI` does this with `StimDelayTrainingEnabled`.

Pass `[]` as `src` when the toggle itself is the control: a non-empty `src` is *disabled* while training runs, which for the toggle would leave the operator no way to switch training back off.

Bound to a parameter, the callback also runs for **external** writes — `gui.components.Parameter_Control` invokes `PostUpdateFcn` on the parameter's `PostSet`, which is what lets a phase load open or close the training window. It is therefore idempotent in both directions: a repeated enable does not re-snapshot over the suspended values, and a disable with no preceding enable returns without trying to restore a snapshot that was never taken. The map entry in `AdaptiveTrainingGUIs` is the record of which state is in effect.

## Call signatures

```matlab
[value, success] = gui.eval_adaptive_training_mode(obj, src, event, Parameter)
[value, success] = gui.eval_adaptive_training_mode(obj, src, event, Parameter, Name=Value)
```

## Behavior

When `event.Value` is true, the callback:

- Stores the current `Parameter.isRandom` state in `Parameter.UserData.ADAPTIVE.isRandom`, and suspends `RepeatDelayOnAbort` the same way — **only** when training was not already on.
- Forces `Parameter.isRandom = false`.
- Opens or focuses a `gui.AdaptiveTraining` window for the parameter.
- Registers a `NewData` listener on `obj.RUNTIME.EVENTS`.

When `event.Value` is false, the callback:

- Returns immediately when training was never switched on, since there is no snapshot to restore.
- Restores the saved `Parameter.isRandom` and `RepeatDelayOnAbort` states.
- Deletes the training GUI for that parameter.
- Deletes the corresponding `NewData` listener.
- Re-enables the source UI control when one was provided.

`RepeatDelayOnAbort` is resolved through `RUNTIME.find_parameter`, not the `RUNTIME.P` cache: that cache is only populated once `TRIALS` is initialized, and the toggle can now be written before a session has dispatched its first trial. A protocol that does not define the parameter simply has nothing to suspend.

Suspending `isRandom` is not enough on its own when something *other* than `hw.Parameter` drives the value. A trial selector writing the parameter into the trials table every trial — as `cl_AppetitiveStimDetect` does for a block-randomized stimulus delay — has to stand down for the duration too, or the two overwrite each other; see [../paradigms/cl_AppetitiveStimDetect.md](../paradigms/cl_AppetitiveStimDetect.md#block-randomized-stimulus-delay).

## Response mapping

The listener decodes the most recent trial response code with `epsych.BitMask.decode` and applies one step when the decoded response matches either configured outcome:

- `StepUpResponse` triggers `h.updateParameter("up")`
- `StepDownResponse` triggers `h.updateParameter("down")`

Supported response names are:

- `"Hit"`
- `"Miss"`
- `"CorrectReject"`
- `"FalseAlarm"`
- `"Abort"`

These are the names `epsych.BitMask.decode` returns; anything else is refused by the
argument validator rather than silently never matching.

## Name-value options

These options are accepted by `gui.eval_adaptive_training_mode`:

- `MinValue`, `MaxValue`
- `StepUp`, `StepDown`
- `StepUpLimits`, `StepDownLimits`
- `MinValueLimits`, `MaxValueLimits`
- `StepUpResponse`, `StepDownResponse`
- `ScaleType`, `ScaleExponent`, `ScaleReference`, `Breakpoints` — the value space the
  steps are taken in (see [AdaptiveTraining](AdaptiveTraining.md))

Every option is forwarded to the `gui.AdaptiveTraining` constructor.
`StepUpResponse` and `StepDownResponse` are *also* retained here: the `NewData`
listener is what acts on them, while the window uses them only to say which outcome
steps which way.

## Runtime requirements

`obj` must expose the following members:

- `RUNTIME`
- `AdaptiveTrainingGUIs`
- `AdaptiveTrainingListeners`

The callback stores GUI handles and listeners in those maps using `Parameter.Name` as the key.

## Hardware-backed parameters

For parameters whose parent is not `hw.Software`, the listener also writes the updated parameter value into the pending trial table:

- Source table: `RUNTIME.TRIALS.trials`
- Lookup map: `RUNTIME.TRIALS.writeParamIdx`

This keeps the trial record aligned with the value that was applied after the response.

A step the rule declines (the parameter has no value yet, or a proportional ladder has reached zero) returns the unstepped value and is **not** written to the table. Dealing a non-numeric value into a column would blank the schedule for the rest of the session.

## The suspended state, and phase loads

Switching training on records what it suspends in `Parameter.UserData.ADAPTIVE` — the parameter's `isRandom`, and `RepeatDelayOnAbort`'s value — and switching it off puts them back.

That snapshot can be carried away mid-session, because `hw.Parameter.fromStruct` assigns `UserData` **wholesale**: loading any phase while training is on replaces it with whatever the phase file recorded. Two cases, both handled, so **no phase file needs re-saving**:

- A phase saved before the staircase → adaptive rename carries the old `UserData.STAIRCASE` key. It is read as an equal alternative — same content, written by an older release — so it restores normally.
- A phase carrying no snapshot at all leaves nothing to restore. Training still switches off cleanly and says so at level 0, rather than throwing: an exception on the way *out* of training mode would abort the teardown and strand the parameter with randomisation suspended, which is the state the operator was trying to leave.

Note that a phase load also restores `isRandom` itself, so a phase loaded during training can un-suspend randomisation on its own. Loading a phase mid-training is worth avoiding for that reason, independently of the snapshot.

## Related documentation

- See `documentation/gui/AdaptiveTraining.md` for the training-window UI and stepping rules.
- See `obj/+gui/@AdaptiveTraining/AdaptiveTraining.m` for the class implementation.
