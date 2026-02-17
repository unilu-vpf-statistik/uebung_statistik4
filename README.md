# Übungen - Statistik IV (FS 2026)

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Übungsmaterialien zur Vorlesung **Statistik IV** an der Universität Luzern im Frühlingssemester 2026.

## Über dieses Repository

Diese Website enthält interaktive Übungen, die Sie durch den gesamten Prozess der reproduzierbaren Datenanalyse mit R führen. Die Übungen behandeln:

- ✅ Reproduzierbare Analysen und Projektorganisation
- ✅ Arbeiten mit R-Projekten und relativen Pfaden
- ✅ Datenimport aus verschiedenen Formaten
- ✅ Datenaufbereitung und -validierung
- ✅ Tidy Data-Prinzipien und Datenumstrukturierung

## Voraussetzungen

Für die Übungen benötigen Sie:

- [R](https://cran.r-project.org/) (Version ≥ 4.0)
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/)
- [Quarto](https://quarto.org/docs/get-started/) (optional, für lokales Rendering)

## Installation der R-Pakete

```r
# Kern-Pakete für die Übungen
install.packages(c("tidyverse", "here", "haven", "readxl", "janitor"))

# Pakete für interaktive Übungsfragen
install.packages(c("exams", "exams2forms"))
```

## Nutzung

Die Übungswebsite können Sie hier aufrufen: [Link zur Website einfügen]

Falls Sie die Website lokal auf Ihrem Computer rendern möchten:

```bash
# Repository klonen
git clone https://github.com/[username]/uebung_statistik4.git
cd uebung_statistik4

# Website mit Quarto rendern
quarto render
```

Die gerenderte Website finden Sie dann im `docs/`-Verzeichnis.

## Struktur

```
├── exercise1.qmd - exercise12.qmd  # 12 Übungsmodule
├── exam_prep.qmd                   # Klausurvorbereitung
├── questions_*/                    # Übungsfragen (.Rmd-Dateien)
├── daten/                          # Beispieldatensätze
└── docs/                           # Gerenderte Website
```

## Lizenz

Dieses Werk ist lizenziert unter [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

**Sie dürfen:**
- Das Material teilen und bearbeiten
- Für beliebige Zwecke nutzen, auch kommerziell

**Unter folgenden Bedingungen:**
- **Namensnennung**: Sie müssen angemessenen Urheber- und Rechtehinweis geben

## Kontakt

**Dozent**: Gidon Frischkorn  
**Institution**: Universität Luzern  
**Semester**: Frühlingssemester 2026

Für Fragen oder Feedback siehe die [Hilfe & Kontakt](about.qmd) Seite auf der Website.

## Beitragen

Haben Sie Fehler gefunden oder Verbesserungsvorschläge? Issues und Pull Requests sind willkommen!

---

[![Universität Luzern](images/Logo_UniLu.png)](https://www.unilu.ch)
