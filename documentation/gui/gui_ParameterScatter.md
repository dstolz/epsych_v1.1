# gui.components.ParameterScatter

A generic scatter plot for custom behavior GUIs that compares any two
per-trial parameters recorded in the current experiment, with an optional
third parameter mapped to marker color.

## What it does

- **X/Y parameter dropdowns**: pick any per-trial parameter for either axis
  at any time; the plot updates immediately.
- **Live updates**: a `NewData` listener refreshes the plot after every
  completed trial.
- **Color-by parameter**: an optional third dropdown maps a parameter to
  marker color with a labeled colorbar (e.g., color by `RespCode` or level).
- **Trial Number**: always offered as a parameter — the chronological DATA
  index (note this differs from `TrialID`, which is the schedule/condition ID).
- **Response**: offered whenever the experiment records a response code (a
  `RespCode` or `ResponseCode` parameter), as a categorical parameter holding
  the outcome name decoded from the raw bitmask via
  `epsych.BitMask.getResponses` — `Hit`, `Miss`, `CorrectReject`,
  `FalseAlarm`, `Abort`, or `Undefined` when no response bit is set. All six
  categories are present from the start, so an outcome keeps the same axis
  position and color across trials and sessions. The raw code remains
  selectable under its own parameter name. `Response` is offered even when
  the response-code parameter itself is `Visible=false`.
- **Populated before the first trial**: when constructed from a runtime, the
  lists are seeded from the parameters the runtime will record, so a GUI built
  at session start is usable immediately rather than offering only
  `Trial Number` until a trial completes.
- **Invisible parameters excluded**: parameters flagged `Visible=false` on
  their `hw.Parameter` never appear in the selectable lists, nor do
  array-valued or write-only parameters. Non-scalar DATA fields are also
  excluded.
- **Categorical (text) parameters**: a scalar char/string DATA field, or a
  runtime parameter with `Type='String'`, is offered in the same dropdowns
  as numeric parameters. On a categorical X/Y axis, points are placed at
  integer positions — one per distinct value seen so far — and the axis
  ticks are labeled with those values (log scale is skipped for that axis).
  As a color-by parameter, each distinct value gets one discrete color and
  the colorbar ticks are labeled instead of showing a continuous scale. A
  value keeps its assigned position/color once seen, even as later trials
  introduce new categories.
- **Aesthetics**: right-click the axes for marker style, size, opacity,
  marker color, colormap (color-by mode), log X/Y, and grid. Each marker is
  outlined in a brighter shade of its own fill, so overlapping trials keep a
  visible boundary. The outline is a second scatter object drawn over the
  first — one marker takes one `CData`, so face and edge cannot carry
  different colors on a single object — and it is inert to the mouse, leaving
  datatips to the fill underneath.
- **Trend lines**: right-click → **Trend Line** overlays a quick fit on the
  points, chosen from
  - *Linear*, *Quadratic*, *Cubic* — least-squares polynomial fits, drawn as a
    smooth curve over the plotted x range;
  - *Moving Average* — a centred running mean over the last **Trend Window**
    trials (5/10/20/50/100 from the right-click menu; the window shrinks at
    the ends of the session and is clamped to the trial count);
  - *Mean per X Value* / *Median per X Value* — one point per distinct x,
    which is the useful one when x is a stimulus level with several trials at
    each step, or a categorical parameter.

  Every option is a single pass over the session or a small least-squares
  solve, so the overlay is recomputed on every completed trial rather than
  cached — on 5000 trials each costs 0.1–2 ms on top of the redraw.

  **Trend Line Color ...** picks the line color, and **Show Trend Statistics**
  reports the fit in the axes title: slope, intercept, R² and n for a line;
  the fit name, R² and n for a higher-order one; the window or the number of
  grouped x values otherwise.

  Two rules follow from a categorical axis holding codes rather than
  quantities — the mean of `Hit` and `Miss` is not a number to read off an
  axis. Nothing is drawn against a **categorical y** at all, and over a
  **categorical x** only the per-value mean and median are offered; a
  polynomial fitted to category codes would be a fit to their arbitrary
  order. In both cases the line is hidden and the title cleared rather than
  raising an error, since the selection that supports a trend usually comes
  back a moment later.

  A polynomial is fitted in `polyfit`'s centred-and-scaled coordinates, so a
  level in dB against a frequency in Hz does not warn about conditioning on
  every redraw; the reported slope is brought back to the axes' units. The
  curve is sampled evenly in the space the axis displays, so it stays smooth
  under **Log X**. The fit itself is always in data space.

  Points the markers already dropped — non-finite values, and points with no
  color-by value — are outside the fit too.
- **Pop-out**: right-click → **Open in Separate Window** (the `gui.PopOut`
  mixin, or the `popOut` method) opens a second, independent scatter over the
  same data — its own selections and aesthetics, so a large exploratory view
  never disturbs the one embedded in the GUI. See
  [gui_PopOut.md](gui_PopOut.md).
- **Persistence**: parameter selections and aesthetics are saved with
  `setpref`/`getpref` (group `epsych2_gui_ParameterScatter`), keyed to the
  hosting figure `Tag`/`Name` or an explicit `PreferenceTag`, and restored
  the next session. Selections passed to the constructor are defaults for the
  first session only — once the user picks a parameter, that choice wins on
  every later launch.
- **Any container, resizable**: host it in a `uifigure`, legacy `figure`,
  panel, tab, or `uigridlayout` cell. uifigure-family containers get a
  `uigridlayout`/`uidropdown` control row; legacy figures get equivalent
  `uicontrol` popupmenus with pixel-accurate resize handling.

## Usage

```matlab
% Online, from a psychophysics object (updates via its Events NewData event)
obj.hScatter = gui.components.ParameterScatter(pObj, parentPanel);

% Online, directly from the runtime (updates via RUNTIME.EVENTS)
obj.hScatter = gui.components.ParameterScatter(RUNTIME, parentPanel, PreferenceTag='MyTaskGUI');

% Offline, from saved trial data (no listener)
S = gui.components.ParameterScatter(DATA, uifigure);

% Programmatic control (updates immediately)
S.XParameter = 'FreqHz';
S.YParameter = 'LevelDB';
S.ColorParameter = 'Response';   % decoded outcome name; or 'RespCode', or '(none)'
S.TrendType = 'movmean';         % running mean; call update to redraw
S.TrendWindow = 20;
S.update;
```

### Constructor

```matlab
obj = gui.components.ParameterScatter(source, container, options)
```

| Input | Description |
|-------|-------------|
| `source` | `psychophysics.*` object, `epsych.Runtime`, or DATA struct array |
| `container` | Figure, panel, tab, or layout host; empty creates a `uifigure` |
| `PreferenceTag` | Optional key for saved preferences (defaults to hosting figure Tag/Name) |
| `BoxID` | Restrict `NewData` updates to these boxes; empty accepts all |
| `XParameter`, `YParameter`, `ColorParameter` | Initial selections, used only when nothing is saved for this `PreferenceTag`; a selection restored from a previous session takes precedence. Applied as soon as the named parameters appear in the data, so they survive construction before the first trial |

### Key properties

| Property | Description |
|----------|-------------|
| `XParameter`, `YParameter` | Selected DATA field names, or `'Trial Number'` / `'Response'` |
| `ColorParameter` | Third parameter for marker color, or `'(none)'` |
| `Marker`, `MarkerSize`, `MarkerColor`, `MarkerAlpha` | Marker aesthetics |
| `ColormapName` | Colormap used in color-by mode |
| `LogX`, `LogY`, `ShowGrid` | Axes aesthetics |
| `TrendType` | Trend overlay: `'none'` (default), `'linear'`, `'quadratic'`, `'cubic'`, `'movmean'`, `'mean'`, `'median'` |
| `TrendWindow` | Moving-average span, in trials |
| `TrendColor`, `ShowTrendStats` | Trend line color; whether the fit is reported in the axes title |
| `TrendH` | The trend line object, for a paradigm that wants to restyle it |

Programmatic changes to the selection properties redraw immediately; after
changing aesthetics programmatically, call `update` to redraw. All of these
are also reachable from the axes' right-click menu, which persists choices
automatically.

## Update cost

A redraw asks for three parameters (x, y, and color-by), and each trial's value
is read once and kept rather than re-read for every parameter on every trial.
A category also keeps the code it was first assigned, so codes are appended the
same way. The dropdown item lists are written only when they actually change:
rewriting `Items` on every trial closed the list under a user who had it open
mid-selection.

Behavior is covered by `tmp/smoke_test_parameter_scatter.m`, and
`tmp/smoke_test_incremental_render.m` proves that a scatter fed trial by trial
plots exactly what one handed the same trials at once plots. The trend
overlays have their own standing proof in `tmp/smoke_test_scatter_trends.m`,
which recovers a known line, quadratic and running mean from the drawn data
and reports what each trend adds to a 5000-trial redraw.

## Cleanup

Store the object on your GUI class and `delete` it in the GUI destructor —
this releases the `NewData` listener and context menu:

```matlab
delete(obj.hScatter);
```

## See also

- [Customized GUI Instructions](../design/Customized_GUI_Instructions.md)
- [gui.components.History](gui_History.md) — trial-by-trial history table with the same
  preference-persistence pattern
- [Event notifications](../epsych/Event_Notifications.md)
