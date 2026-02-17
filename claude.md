# Statistik IV - Übungen (FS 2026)

## Project Overview

This is a Quarto-based website containing exercise materials for the **Statistics IV** course at the University of Lucerne, Spring Semester 2026. The course teaches reproducible data analysis workflows in R.

## Course Information

- **Instructor**: Gidon Frischkorn
- **Semester**: FS 2026
- **Institution**: Universität Luzern
- **License**: CC BY 4.0
- **Exam**: MC (Single Choice & K-Prim), BYOD, Do. 11. Juni 2026, 13–14 Uhr; ca. 2 Fragen pro Sitzung; Formelsammlung bereitgestellt

## Course Character & Pedagogical Approach

**This course is primarily about the data analysis process and tooling, not classical statistics methods.**
Only the last 2 substantive sessions cover statistical procedures (ANOVA, regression). The first 10 sessions cover workflow, tooling, and data handling.

### Didactic Priorities (from course design)

1. Konzeptuelle Erklärung vor formaler Darstellung
2. Analyseentscheidungen vor Rechenlogik
3. Interpretation vor Technik
4. Begründungen > Code-Rezepte

### What the exam tests (confirmed from slides)

- Erkennen guter vs. schlechter Coding-Praxis
- Verständnis von Analyse-Entscheidungen
- Lesen und Verständnis von R-Code
- Szenarien zur Anwendung statistischer Analysen beurteilen
- Prinzipien reproduzierbarer Analysen benennen

### What the exam does NOT test

- Detailwissen zu einzelnen R-Paketen und Funktionen
- Auswendig lernen von R-Syntax
- Schreiben von R-Code unter Zeitdruck

### Session Structure (3 blocks per session)

- **Block 1** (~45 Min): Konzeptueller Input
- **Block 2** (~20–25 Min): Eigenständige Anwendung in R
- **Block 3** (~20 Min): Lösung, Diskussion, Analyseentscheidungen

## Course Topics (13 Sessions — authoritative order from slides)

| Session | Titel | Exercise file |
| ------- | ----- | ------------- |
| 1 | Reproduzierbare Datenanalysen | exercise1.qmd |
| 2 | R-Projekte & Dateiorganisation | exercise2.qmd |
| 3 | Daten importieren & prüfen | exercise3.qmd |
| 4 | Datenaufbereitung I: Tidy Data & Umkodierung | exercise4.qmd |
| 5 | Datenaufbereitung II: Fehlende Werte & Ausreisser | exercise5.qmd |
| 6 | Grundlagen: Programmieren mit R (eigene Funktionen) | exercise6.qmd |
| 7 | Deskriptive Statistik berechnen | exercise7.qmd |
| 8 | Datenvisualisierung I: Grundlagen ggplot2 | exercise8.qmd |
| 9 | Datenvisualisierung II: Erweiterungen | exercise9.qmd |
| 10 | Ergebnisberichte in R: Quarto & Markdown | exercise10.qmd |
| 11 | Anwendung I: Gruppenvergleiche & ANOVA | exercise11.qmd |
| 12 | Anwendung II: Regression & Vorhersagen | exercise12.qmd |
| 13 | Repetitorium & Prüfungsvorbereitung | exam_prep.qmd |

## Project Structure

```text
├── _quarto.yml              # Quarto website configuration
├── index.qmd                # Homepage
├── about.qmd                # Help & contact page
├── Checklisten.qmd          # Checklists page
├── Funktionsübersicht.qmd   # Function overview
├── exam_prep.qmd            # Exam preparation (Session 13)
├── exercise1.qmd            # Session 1: Reproduzierbare Datenanalysen (vollständig)
├── exercise2.qmd            # Session 2: R-Projekte & Dateiorganisation (vollständig)
├── exercise3.qmd            # Session 3: Daten importieren & prüfen (vollständig)
├── exercise4.qmd            # Session 4: Datenaufbereitung I (vollständig)
├── exercise5.qmd            # Session 5: Datenaufbereitung II (vollständig)
├── exercise6.qmd            # Session 6: Programmieren mit R (stub)
├── exercise7.qmd            # Session 7: Deskriptive Statistik (stub)
├── exercise8.qmd            # Session 8: Visualisierung I (stub)
├── exercise9.qmd            # Session 9: Visualisierung II (stub)
├── exercise10.qmd           # Session 10: Quarto & Markdown (stub)
├── exercise11.qmd           # Session 11: Gruppenvergleiche & ANOVA (stub)
├── exercise12.qmd           # Session 12: Regression & Vorhersagen (stub)
├── styles.css               # Custom CSS styling
├── webex.js                 # Interactive question functionality
├── daten/                   # Data files for exercises
│   ├── WM_Fragebögen.csv    # Used in Sessions 3–5 (working memory study)
│   └── Lab_Kodierung.dat    # Used in Sessions 3–5 (lab coding data)
├── images/                  # Images and logos
├── local/ -> OneDrive       # Gitignored; synced to colleague via OneDrive
│   ├── slides/              # PPTX lecture slides (Sessions 1–5 exist)
│   └── uebungen/            # Sample student projects & exercise scripts
└── questions_*/             # Exercise question banks (.Rmd files)
    ├── questions_uebung1/   # 3 questions
    ├── questions_uebung2/   # 3 questions
    ├── questions_uebung3/   # 3 questions
    ├── questions_uebung4/   # 3 questions
    ├── questions_uebung5/   # 3 questions
    └── questions_exam_prep/ # 5 questions (covering Sessions 1–5)
```

## Technology Stack

- **Quarto** — Document authoring and website generation; also taught in Session 10
- **R** — Statistical programming language (tool, not learning goal)
- **exams** & **exams2forms** — Generate interactive questions with randomization
- **tidyverse** — Core data wrangling; dplyr, tidyr, purrr, stringr
- **ggplot2** — Data visualization (Sessions 8–9)
- **here** — Path management (relative paths)
- **haven** & **readxl** — Data import from SPSS/Excel

## Building the Website

```r
quarto::quarto_render()
```

Or from the terminal:

```bash
quarto render
```

The rendered site is output to the `docs/` directory.

## Question Structure

Each exercise has a corresponding `questions_uebungX/` folder with `.Rmd` files.
Loaded via the `exams` package; questions are shuffled randomly on each render.
Question style: Single-Choice and K-Prim items, focused on conceptual understanding and analysis decisions.

## Key Notes for Content Development

- All content in **German** (target audience: German-speaking BSc Psychology students, 4th semester)
- Prerequisite knowledge: Deskriptivstatistik, Hypothesentests, lineare Modelle (earlier semesters)
- No prior knowledge of advanced math, measure theory, or Bayesian inference assumed
- The `local/` directory is gitignored and synced to OneDrive for collaboration
- Slides 1–5 exist in `local/slides/` as `.pptx` files; slides 6–13 are yet to be created
- Exercise files 6–12 are stubs — to be expanded during the semester

## Content Priorities When Creating Questions or Materials

1. **Analyseentscheidungen** — When is a method appropriate? Why?
2. **Fehlinterpretationen** — What are typical wrong conclusions and why are they wrong?
3. **Modellannahmen** — What must hold, what are consequences of violations?
4. **Reproduzierbarkeit** — File structure, relative paths, Quarto, version control
5. **Code lesen** — Understanding what R code does conceptually, not writing it from scratch

## ChatGPT System Prompt Context

A ChatGPT system prompt (file: `local/themenuebersicht.md`) was used to pre-generate course materials.
When generating questions, slide content, or explanations, Claude should follow the same constraints:

- Strictly conceptual understanding, no calculation-focused items
- MC-compatible framing (Single Choice & K-Prim)
- Psychologisch kontextualisiert
- No software tutorial style, no step-by-step coding guides
- See `local/themenuebersicht.md` for the full session-by-session content plan
