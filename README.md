# Time-Resolved IR Spectroscopy Processing Pipeline

MATLAB pipeline for processing time-resolved IR (reaction monitoring) spectra:
background subtraction, baseline correction (airPLS / ALS / two-point linear),
PCA, and MCR-ALS resolution of pure component spectra and concentration
profiles.

This project was built to analyze time-resolved IR spectra of the
hydroformylation (oxo) process, in which an alkene is converted to a
higher aldehyde in the presence of syngas, using Rh(acac)(CO)₂ with the
Alkanox ligand as catalyst.

## Pipeline overview

Scripts are prefixed with a letter indicating run order (A → B → C → ... → I).
`F` has three alternative baseline-correction methods — run **one** of them,
not all three, before moving on to `G`.

| Step | Script | What it does |
|------|--------|---------------|
| — | `src/pipeline/A_waterfall_plot.m` | 3D waterfall plot of the raw imported spectra (diagnostic, can be run any time after import) |
| B | `src/pipeline/B_Trim_data_background.m` | Trims the raw dataset to the background time window and wavenumber range |
| C | `src/pipeline/C_Background__average.m` | Averages the background spectra into a single reference spectrum |
| D | `src/pipeline/D_Trim_data_reaction_zone.m` | Trims the raw dataset to the reaction time window |
| E | `src/pipeline/E_Reaction_back_remove.m` | Subtracts the averaged background from the reaction-zone spectra |
| F | `src/pipeline/F_A_Baseline_correction_airPLS.m` | **Option A** — baseline correction via airPLS + Savitzky-Golay smoothing |
| F | `src/pipeline/F_B_Baseline_correction_ALS.m` | **Option B** — baseline correction via ALS + Savitzky-Golay smoothing |
| F | `src/pipeline/F_C_Baseline_Linear.m` | **Option C** — two-point linear baseline correction + Savitzky-Golay smoothing |
| G | `src/pipeline/G_PCA_Run_Analysis.m` | PCA on the baseline-corrected spectra (loadings, scores, scree plot) |
| H | `src/pipeline/H_Run_MCR.m` | Runs MCR-ALS (via an external toolbox — see below) |
| I | `src/pipeline/I_Save_MCR_ALS.m` | Saves and plots the resolved MCR-ALS concentration/spectra profiles |

## How each file works

### Functions (`src/functions/`)
Reusable baseline-correction routines called by the pipeline scripts above —
not meant to be run on their own.

| File | What it does |
|------|---------------|
| `airPLS.m` | Estimates and removes a curved baseline from a single spectrum using adaptive iteratively reweighted penalized least squares — iteratively down-weights points above the current baseline estimate so the fit hugs the lower envelope of the signal. |
| `ALS.m` | Estimates and removes a baseline using asymmetric least squares — similar idea to airPLS but with a fixed asymmetry parameter `p` controlling how strongly it favors points below vs. above the fit. |
| `linear_baseline_correction.m` | Draws a straight line between two user-specified wavenumber points and subtracts it — the simplest baseline method, good when you're confident the baseline is flat/linear across your region of interest. |

### Pipeline scripts (`src/pipeline/`)
Run in order to go from raw imported data to resolved pure components.

| File | What it does |
|------|---------------|
| `A_waterfall_plot.m` | Diagnostic 3D surface plot of all raw imported spectra (wavenumber × sample number × intensity) — a quick visual sanity check of the raw dataset. |
| `B_Trim_data_background.m` | Loads the raw imported data, crops it to the background time window and wavenumber range, saves `background_data.mat`. |
| `C_Background__average.m` | Averages all background spectra into a single reference spectrum, saves `Background__avg.mat`. |
| `D_Trim_data_reaction_zone.m` | Loads the raw imported data, crops it to the reaction time window and wavenumber range, saves `reaction_zone_with_background.mat`. |
| `E_Reaction_back_remove.m` | Subtracts the averaged background spectrum from every reaction-zone spectrum, saves `reaction_zone_without_background.mat`. |
| `F_A_Baseline_correction_airPLS.m` | **Baseline option A** — applies airPLS + Savitzky-Golay smoothing to every reaction spectrum, saves `airPLS_corrected.mat`. |
| `F_B_Baseline_correction_ALS.m` | **Baseline option B** — applies ALS + Savitzky-Golay smoothing to every reaction spectrum, saves `ALS_corrected.mat`. |
| `F_C_Baseline_Linear.m` | **Baseline option C** — applies a two-point linear baseline + Savitzky-Golay smoothing, saves `TwoPoint_corrected.mat`. (Run only one of F_A/F_B/F_C.) |
| `G_PCA_Run_Analysis.m` | Runs PCA on the baseline-corrected spectra: how many components explain 95% of the variance, plus plots of loadings (spectral shapes) and scores (time profiles). Exploratory step before MCR. |
| `H_Run_MCR.m` | Loads the baseline-corrected spectra and launches the external MCR-ALS toolbox to resolve pure component spectra and their concentration profiles. |
| `I_Save_MCR_ALS.m` | Saves the MCR-ALS results (`copt`, `sopt`) to `MCR_Final_Results.mat` and plots the resolved concentration profiles and pure spectra, with automatic peak labeling. |

## Repository layout

```
.
├── data/
│   ├── raw/          # raw imported spectra (.mat)
│   └── processed/    # intermediate and final .mat files produced by the pipeline — gitignored
├── docs/              # extra notes / figures (optional)
├── external/          # third-party toolboxes you install locally (e.g. MCR-ALS) — gitignored
├── src/
│   ├── functions/     # reusable baseline-correction functions
│   └── pipeline/      # the lettered A–I pipeline scripts
├── .gitignore
├── LICENSE
└── README.md
```

## Requirements

- MATLAB (developed/tested on R2021b or later; adjust if you know your actual version)
- Signal Processing Toolbox (`sgolayfilt`)
- Statistics and Machine Learning Toolbox (`pca`)
- The MCR-ALS toolbox for step H — see below for where to get it and how it's used here.

## Data format

Scripts expect three variables per `.mat` file:

- `D` — intensity matrix, rows = samples/time points, columns = wavenumbers
- `x` — wavenumber vector (columns of `D`)
- `t` — time vector (rows of `D`)

## Getting started

1. Clone the repo.
2. Place your raw imported spectra `.mat` file (containing `D`, `x`, `t`)
   in `data/raw/`.
3. Open MATLAB in the repo root and run the pipeline scripts in order:
   `B → C → D → E → one of the F options → G → H → I`.
   Each script writes its output into `data/processed/` for the next step
   to pick up.

## Third-party code: MCR-ALS toolbox (step H)

`H_Run_MCR.m` is a thin wrapper around the **MCR-ALS toolbox**, a MATLAB-based
graphical user interface for resolving overlapping signals in complex
mixtures (originally developed for chromatographic data, and widely used
since for spectroscopic data including IR and Raman).

**Original authors / origin**: the toolbox is developed and maintained by
**Romà Tauler**, **Joaquim Jaumot**, and **Anna de Juan** (IDAEA-CSIC and
Universitat de Barcelona). The original code, tutorials and example
datasets are distributed from the authors' Multivariate Curve Resolution
homepage and archived on Zenodo:

- Multivariate Curve Resolution homepage (original distribution site):
  https://www.cid.csic.es/homes/rtaqam/tmp/WEB_MCR/
- MCR-ALS 2.0 toolbox archive (Zenodo, DOI 10.5281/zenodo.6334791):
  https://zenodo.org/records/6334791

**License**: the Zenodo-archived release of this toolbox (matching the
`mcr_toolbox2_updated_070721` package used here) is published by the
original authors under **[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)**
(Creative Commons Attribution 4.0 International), which permits
redistribution and modification provided appropriate credit is given to
the original authors. If your local copy of the toolbox includes its own
license or readme file, that file takes precedence over this note — check
for one before publishing.

**This repository's modifications**: the copy of the toolbox used here has
been adapted from the authors' original release so that it runs under
newer MATLAB versions. It is kept out of this git repo (see `.gitignore`)
and must be installed locally — see Requirements and `H_Run_MCR.m`'s own
header for how it's located at runtime (`MCR_TOOLBOX_PATH` or the fallback
path inside the script).

**References** — please cite these if you publish results produced with
this toolbox:

1. Jaumot, J., Gargallo, R., de Juan, A., & Tauler, R. (2005). A graphical
   user-friendly interface for MCR-ALS: a new tool for multivariate curve
   resolution in MATLAB. *Chemometrics and Intelligent Laboratory Systems*,
   76(1), 101–110. https://doi.org/10.1016/j.chemolab.2004.12.007
2. Jaumot, J., de Juan, A., & Tauler, R. (2015). MCR-ALS GUI 2.0: New
   features and applications. *Chemometrics and Intelligent Laboratory
   Systems*, 140, 1–12. https://doi.org/10.1016/j.chemolab.2014.10.003

**How to use it (brief)**: `H_Run_MCR.m` loads the baseline-corrected data
and calls the toolbox's main routine, `mcr_main`, which opens the MCR-ALS
GUI. From there, the typical workflow is:

1. Load the data matrix (already done for you — `D`, `x`, `t` are in the
   workspace when the GUI launches).
2. Choose the number of components to resolve (informed by the PCA step,
   `G_PCA_Run_Analysis.m`).
3. Select initial estimates for the pure spectra or concentration profiles
   (e.g. via SIMPLISMA, or your own estimates).
4. Apply constraints as appropriate for your chemistry — non-negativity
   (concentrations and/or spectra can't be negative) and unimodality
   (a concentration profile should rise and fall only once) are common
   choices for reaction-monitoring data like this.
5. Run the ALS optimization and inspect the fit (lack of fit / % variance
   explained).
6. Export the results as `copt` (concentrations) and `sopt` (spectra) —
   `I_Save_MCR_ALS.m` picks these up and saves/plots them.

For full usage details beyond this summary, consult the toolbox's own
tutorials, linked from the homepage above.

## Known issues / things to double-check before relying on this

- **Hardcoded trim windows**: the wavenumber range and the row ranges used
  to split background vs. reaction zone in `B_Trim_data_background.m` and
  `D_Trim_data_reaction_zone.m` are specific to one dataset's acquisition
  layout. Check/update these before reusing the pipeline on different data.
- **MCR-ALS toolbox path**: `H_Run_MCR.m` resolves the toolbox location via
  an `MCR_TOOLBOX_PATH` environment variable with a local fallback path —
  update the fallback if you install the toolbox somewhere else.
- **Large/raw data**: `data/raw/*.mat` is not tracked by git by default
  (see `.gitignore`). If you want the repo to be runnable immediately after
  cloning, consider [Git LFS](https://git-lfs.com/) for that file, or host
  it externally and link to it here.
- `.asv` files (MATLAB autosave backups) are intentionally excluded.

## License

MIT — see `LICENSE` — applies to the original code in this repository only.
The bundled/adapted MCR-ALS toolbox remains the work of its original
authors (Tauler, Jaumot, de Juan) and is distributed by them under
CC BY 4.0 — see the Third-party code section above.
