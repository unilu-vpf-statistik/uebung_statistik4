# =============================================================================
# generate_r_plots.R — Batch plot generation for Statistik IV lecture slides
# Generates all R-based PNG plots for sessions S07–S12
# Output: local/Vorlesung/plots/SXX_FYY_name.png (2400×1600px, 300 dpi)
# =============================================================================

library(tidyverse)
library(patchwork)

# --- Configuration ---
output_dir <- "local/Vorlesung/plots"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
W <- 2400; H <- 1600; DPI <- 300

save_plot <- function(filename, plot, w = W, h = H, dpi = DPI) {
  path <- file.path(output_dir, filename)
  ggsave(path, plot, width = w / dpi, height = h / dpi, dpi = dpi, bg = "white")
  cat("Saved:", path, "\n")
}

# --- Theme for slides (large text, clean) ---
theme_slide <- function(base_size = 16) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size * 1.2),
      plot.subtitle = element_text(size = base_size * 0.9, color = "grey40"),
      strip.text = element_text(face = "bold", size = base_size),
      legend.position = "bottom",
      legend.text = element_text(size = base_size * 0.85),
      panel.grid.minor = element_blank()
    )
}

# --- Data preparation ---
wm <- read_csv2("daten/WM_Fragebögen.csv", show_col_types = FALSE)

lab <- read_tsv("daten/Lab_Kodierung.dat", show_col_types = FALSE) |>
  mutate(
    id = as.integer(str_extract(id_raw, "\\d+")),
    gruppe = case_when(
      str_detect(tolower(group_raw), "kontroll|control|ctrl|con") ~ "KG",
      str_detect(tolower(group_raw), "stress") ~ "EG",
      TRUE ~ NA_character_
    )
  ) |>
  filter(!is.na(gruppe)) |>
  select(id, gruppe) |>
  distinct(id, .keep_all = TRUE)

daten <- wm |>
  left_join(lab, by = "id") |>
  filter(!is.na(gruppe)) |>
  mutate(
    session = as.integer(str_extract(session_code, "^\\d+")),
    geschlecht = factor(gender, levels = c("m", "f"),
                        labels = c("Männlich", "Weiblich"))
  )

cat("Data prepared:", nrow(daten), "rows,",
    sum(daten$gruppe == "KG"), "KG,",
    sum(daten$gruppe == "EG"), "EG\n")

# Color palette
col_kg <- "#2E86C1"   # Blue
col_eg <- "#E74C3C"   # Red
cols_gruppe <- c("KG" = col_kg, "EG" = col_eg)


# =============================================================================
# S07 — Deskriptive Statistik (4 plots)
# =============================================================================
cat("\n--- S07 Plots ---\n")

# F09: Two histograms — symmetric vs. right-skewed with M/Mdn
set.seed(42)
sym_data <- tibble(x = rnorm(500, 50, 10), Verteilung = "Symmetrisch")
skew_data <- tibble(x = rexp(500, 0.05) + 20, Verteilung = "Rechtsschief")
demo_data <- bind_rows(sym_data, skew_data) |>
  mutate(Verteilung = factor(Verteilung, levels = c("Symmetrisch", "Rechtsschief")))

demo_stats <- demo_data |>
  group_by(Verteilung) |>
  summarise(M = mean(x), Mdn = median(x), .groups = "drop")

p_s07_f09 <- ggplot(demo_data, aes(x = x)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "grey70", color = "white") +
  geom_vline(data = demo_stats, aes(xintercept = M, color = "Mittelwert"),
             linewidth = 1.2, linetype = "dashed") +
  geom_vline(data = demo_stats, aes(xintercept = Mdn, color = "Median"),
             linewidth = 1.2) +
  scale_color_manual(values = c("Mittelwert" = "red", "Median" = "blue"),
                     name = "") +
  facet_wrap(~Verteilung, scales = "free_x") +
  labs(title = "Lagemaße bei verschiedenen Verteilungsformen",
       x = "Wert", y = "Dichte") +
  theme_slide()
save_plot("S07_F09_histogramme.png", p_s07_f09)

# F10: Streuung — Boxplot with IQR + Normal curve with SD
p_box <- ggplot(daten, aes(y = wm_score)) +
  geom_boxplot(width = 0.3, fill = "grey80", outlier.shape = 21) +
  annotate("segment", x = -0.35, xend = -0.35,
           y = quantile(daten$wm_score, 0.25, na.rm = TRUE),
           yend = quantile(daten$wm_score, 0.75, na.rm = TRUE),
           color = col_eg, linewidth = 2) +
  annotate("text", x = -0.45, y = median(daten$wm_score, na.rm = TRUE),
           label = "IQR", color = col_eg, fontface = "bold", size = 6, hjust = 1) +
  labs(title = "Boxplot mit IQR", x = "", y = "WM-Score") +
  theme_slide() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

m_wm <- mean(daten$wm_score, na.rm = TRUE)
sd_wm <- sd(daten$wm_score, na.rm = TRUE)
x_range <- seq(m_wm - 3.5 * sd_wm, m_wm + 3.5 * sd_wm, length.out = 300)
norm_df <- tibble(x = x_range, y = dnorm(x, m_wm, sd_wm))

p_norm <- ggplot(norm_df, aes(x, y)) +
  geom_line(linewidth = 1) +
  geom_area(data = filter(norm_df, x >= m_wm - sd_wm & x <= m_wm + sd_wm),
            alpha = 0.3, fill = col_kg) +
  geom_area(data = filter(norm_df, x >= m_wm - 2*sd_wm & x <= m_wm + 2*sd_wm),
            alpha = 0.15, fill = col_kg) +
  geom_vline(xintercept = m_wm, linewidth = 1, linetype = "dashed") +
  annotate("text", x = m_wm, y = max(norm_df$y) * 1.05, label = "M",
           fontface = "bold", size = 6) +
  annotate("segment", x = m_wm - sd_wm, xend = m_wm + sd_wm,
           y = -0.001, yend = -0.001, color = col_kg, linewidth = 2) +
  annotate("text", x = m_wm, y = -0.003, label = "±1 SD",
           color = col_kg, fontface = "bold", size = 5) +
  labs(title = "Normalverteilung mit SD-Bereichen",
       x = "WM-Score", y = "Dichte") +
  theme_slide()

p_s07_f10 <- p_box + p_norm + plot_layout(widths = c(1, 2))
save_plot("S07_F10_streuung.png", p_s07_f10)

# F12: Histogram of wm_score with M and Mdn lines
p_s07_f12 <- ggplot(daten, aes(x = wm_score)) +
  geom_histogram(bins = 20, fill = "grey70", color = "white") +
  geom_vline(aes(xintercept = mean(wm_score, na.rm = TRUE)),
             color = "red", linewidth = 1.2, linetype = "dashed") +
  geom_vline(aes(xintercept = median(wm_score, na.rm = TRUE)),
             color = "blue", linewidth = 1.2) +
  annotate("text", x = m_wm + 1, y = Inf, label = paste0("M = ", round(m_wm, 1)),
           color = "red", vjust = 2, hjust = 0, size = 5, fontface = "bold") +
  annotate("text", x = median(daten$wm_score, na.rm = TRUE) - 1, y = Inf,
           label = paste0("Mdn = ", round(median(daten$wm_score, na.rm = TRUE), 1)),
           color = "blue", vjust = 3.5, hjust = 1, size = 5, fontface = "bold") +
  labs(title = "Verteilung der WM-Scores",
       subtitle = "Rote gestrichelte Linie = Mittelwert, Blaue Linie = Median",
       x = "WM-Score (Punkte)", y = "Häufigkeit") +
  theme_slide()
save_plot("S07_F12_wm_histogram.png", p_s07_f12)

# F14: Overlapping density curves KG vs. EG
p_s07_f14 <- ggplot(daten, aes(x = wm_score, fill = gruppe, color = gruppe)) +
  geom_density(alpha = 0.3, linewidth = 1) +
  scale_fill_manual(values = cols_gruppe) +
  scale_color_manual(values = cols_gruppe) +
  labs(title = "WM-Score nach Gruppe",
       subtitle = "Überlappende Dichtekurven",
       x = "WM-Score (Punkte)", y = "Dichte",
       fill = "Gruppe", color = "Gruppe") +
  theme_slide()
save_plot("S07_F14_density_gruppen.png", p_s07_f14)


# =============================================================================
# S08 — Visualisierung I (~6 plots)
# =============================================================================
cat("\n--- S08 Plots ---\n")

# F08: Anscombe's quartet
anscombe_long <- datasets::anscombe |>
  pivot_longer(everything(),
               names_to = c(".value", "set"),
               names_pattern = "(.)(.)")

p_s08_f08 <- ggplot(anscombe_long, aes(x, y)) +
  geom_point(size = 3, color = col_kg) +
  geom_smooth(method = "lm", se = FALSE, color = col_eg, linewidth = 1) +
  facet_wrap(~set, ncol = 2, labeller = labeller(set = c(
    "1" = "Set 1: Linear", "2" = "Set 2: Gekrümmt",
    "3" = "Set 3: Ausreisser", "4" = "Set 4: 1 Extremwert"))) +
  labs(title = "Anscombe's Quartett",
       subtitle = "Identische Deskriptivstatistik (M, SD, r) — völlig verschiedene Muster",
       x = "x", y = "y") +
  theme_slide()
save_plot("S08_F08_anscombe.png", p_s08_f08)

# F11: 4 geoms overview (scatter, bar, box, histogram)
p_scatter <- ggplot(daten, aes(x = age, y = wm_score)) +
  geom_point(alpha = 0.5, color = col_kg) +
  labs(title = "geom_point()", x = "Alter", y = "WM-Score") +
  theme_slide(14)

p_bar <- ggplot(daten, aes(x = gruppe)) +
  geom_bar(fill = col_kg) +
  labs(title = "geom_bar()", x = "Gruppe", y = "Anzahl") +
  theme_slide(14)

p_box_geom <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "geom_boxplot()", x = "Gruppe", y = "WM-Score") +
  theme_slide(14)

p_hist_geom <- ggplot(daten, aes(x = wm_score)) +
  geom_histogram(bins = 20, fill = col_kg, color = "white") +
  labs(title = "geom_histogram()", x = "WM-Score", y = "Häufigkeit") +
  theme_slide(14)

p_s08_f11 <- (p_scatter + p_bar) / (p_box_geom + p_hist_geom) +
  plot_annotation(title = "Vier Basis-Geome in ggplot2",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S08_F11_geome_uebersicht.png", p_s08_f11)

# F14: Good vs. bad visualization
# Good: boxplot for group comparison
p_good <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Gute Darstellung: Boxplot",
       x = "Gruppe", y = "WM-Score (Punkte)") +
  theme_slide(14)

# Bad: pie chart (misleading for comparison)
daten_pie <- daten |>
  group_by(gruppe) |>
  summarise(M = mean(wm_score, na.rm = TRUE), .groups = "drop")

p_bad <- ggplot(daten_pie, aes(x = "", y = M, fill = gruppe)) +
  geom_col(width = 1) +
  coord_polar("y") +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Schlechte Darstellung: Torte",
       fill = "Gruppe") +
  theme_void(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 17))

p_s08_f14 <- p_good + p_bad +
  plot_annotation(title = "Gleiche Daten — verschiedene Darstellung",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S08_F14_gut_vs_schlecht.png", p_s08_f14)

# F16: One variable — histogram + bar chart
p_hist_one <- ggplot(daten, aes(x = wm_score)) +
  geom_histogram(bins = 20, fill = col_kg, color = "white") +
  labs(title = "Metrisch → Histogramm",
       subtitle = "geom_histogram()",
       x = "WM-Score", y = "Häufigkeit") +
  theme_slide(14)

p_bar_one <- ggplot(daten, aes(x = gruppe)) +
  geom_bar(fill = col_eg) +
  labs(title = "Kategorial → Balkendiagramm",
       subtitle = "geom_bar()",
       x = "Gruppe", y = "Anzahl") +
  theme_slide(14)

p_s08_f16 <- p_hist_one + p_bar_one +
  plot_annotation(title = "Eine Variable darstellen",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S08_F16_eine_variable.png", p_s08_f16)

# F17: Two variables — scatter + boxplot + grouped bar
p_scatter2 <- ggplot(daten, aes(x = age, y = wm_score)) +
  geom_point(alpha = 0.5, color = col_kg) +
  geom_smooth(method = "lm", se = FALSE, color = col_eg) +
  labs(title = "Metrisch × Metrisch",
       subtitle = "geom_point()",
       x = "Alter", y = "WM-Score") +
  theme_slide(12)

p_box2 <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Kategorial × Metrisch",
       subtitle = "geom_boxplot()",
       x = "Gruppe", y = "WM-Score") +
  theme_slide(12)

p_gbar <- ggplot(daten |> filter(!is.na(geschlecht)),
                 aes(x = gruppe, fill = geschlecht)) +
  geom_bar(position = "dodge") +
  labs(title = "Kategorial × Kategorial",
       subtitle = 'geom_bar(position = "dodge")',
       x = "Gruppe", fill = "Geschlecht", y = "Anzahl") +
  theme_slide(12)

p_s08_f17 <- p_scatter2 + p_box2 + p_gbar +
  plot_annotation(title = "Zwei Variablen darstellen",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S08_F17_zwei_variablen.png", p_s08_f17)

# F18: Misleading graphs — 4 pairs (bad vs good)
# 1. Truncated y-axis
daten_summary <- daten |>
  group_by(gruppe) |>
  summarise(M = mean(wm_score, na.rm = TRUE), .groups = "drop")

p_trunc_bad <- ggplot(daten_summary, aes(x = gruppe, y = M, fill = gruppe)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  coord_cartesian(ylim = c(50, 70)) +
  labs(title = "Schlecht: Y-Achse\nabgeschnitten", x = "", y = "M") +
  theme_slide(11)

p_trunc_good <- ggplot(daten_summary, aes(x = gruppe, y = M, fill = gruppe)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Gut: Y-Achse\nbei 0", x = "", y = "M") +
  theme_slide(11)

# 2. Missing labels
p_nolabel <- ggplot(daten, aes(x = gruppe, y = wm_score)) +
  geom_boxplot() +
  labs(title = "Schlecht: Keine\nBeschriftung", x = "", y = "") +
  theme_slide(11)

p_label <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Gut: Klare\nBeschriftung",
       x = "Versuchsgruppe", y = "WM-Score (Punkte)") +
  theme_slide(11)

p_s08_f18 <- (p_trunc_bad + p_trunc_good + p_nolabel + p_label) +
  plot_layout(ncol = 4) +
  plot_annotation(title = "Irreführende vs. korrekte Grafiken",
                  theme = theme(plot.title = element_text(face = "bold", size = 18)))
save_plot("S08_F18_irrefuehrend.png", p_s08_f18)


# =============================================================================
# S09 — Visualisierung II (~9 plots)
# =============================================================================
cat("\n--- S09 Plots ---\n")

# F08: Progression — simple → colored → faceted boxplot
p_simple <- ggplot(daten, aes(x = gruppe, y = wm_score)) +
  geom_boxplot() +
  labs(title = "1. Einfach", x = "Gruppe", y = "WM-Score") +
  theme_slide(13)

p_color <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "2. + Farbe", x = "Gruppe", y = "WM-Score") +
  theme_slide(13)

p_facet <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  facet_wrap(~session) +
  labs(title = "3. + Facetten", x = "Gruppe", y = "WM-Score") +
  theme_slide(13)

p_s09_f08 <- p_simple + p_color + p_facet +
  plot_layout(widths = c(1, 1, 2)) +
  plot_annotation(title = "Von einfach zu komplex",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S09_F08_progression.png", p_s09_f08)

# F09: facet_wrap — 4 panels by session
p_s09_f09 <- ggplot(daten, aes(x = wm_score)) +
  geom_histogram(bins = 15, fill = col_kg, color = "white") +
  facet_wrap(~session, ncol = 2) +
  labs(title = "facet_wrap(~session)",
       subtitle = "Ein Panel pro Sitzung",
       x = "WM-Score", y = "Häufigkeit") +
  theme_slide()
save_plot("S09_F09_facet_wrap.png", p_s09_f09)

# F10: wrap vs grid
p_wrap <- ggplot(daten, aes(x = wm_score, fill = gruppe)) +
  geom_histogram(bins = 12, color = "white", show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  facet_wrap(~gruppe, ncol = 1) +
  labs(title = "facet_wrap(~gruppe)", x = "WM-Score", y = "Häufigkeit") +
  theme_slide(13)

p_grid <- ggplot(daten, aes(x = wm_score, fill = gruppe)) +
  geom_histogram(bins = 12, color = "white", show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  facet_grid(gruppe ~ session) +
  labs(title = "facet_grid(gruppe ~ session)", x = "WM-Score", y = "Häufigkeit") +
  theme_slide(13)

p_s09_f10 <- p_wrap + p_grid +
  plot_layout(widths = c(1, 3)) +
  plot_annotation(title = "facet_wrap vs. facet_grid",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S09_F10_wrap_vs_grid.png", p_s09_f10)

# F11: Error bars — with vs without
daten_eb <- daten |>
  group_by(gruppe) |>
  summarise(
    M = mean(wm_score, na.rm = TRUE),
    SD = sd(wm_score, na.rm = TRUE),
    N = n(),
    SE = SD / sqrt(N),
    CI = qt(0.975, N - 1) * SE,
    .groups = "drop"
  )

p_noerr <- ggplot(daten_eb, aes(x = gruppe, y = M, fill = gruppe)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Ohne Fehlerbalken",
       subtitle = "Gruppen unterscheiden sich?",
       x = "Gruppe", y = "Mittlerer WM-Score") +
  theme_slide(14)

p_err <- ggplot(daten_eb, aes(x = gruppe, y = M, fill = gruppe)) +
  geom_col(show.legend = FALSE) +
  geom_errorbar(aes(ymin = M - CI, ymax = M + CI), width = 0.2, linewidth = 0.8) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Mit 95%-CI",
       subtitle = "Deutliche Überlappung!",
       x = "Gruppe", y = "Mittlerer WM-Score") +
  theme_slide(14)

p_s09_f11 <- p_noerr + p_err +
  plot_annotation(title = "Fehlerbalken zeigen Unsicherheit",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S09_F11_fehlerbalken.png", p_s09_f11)

# F12: CI overlap interpretation
p_s09_f12 <- ggplot(daten_eb, aes(x = gruppe, y = M, color = gruppe)) +
  geom_point(size = 5) +
  geom_errorbar(aes(ymin = M - CI, ymax = M + CI), width = 0.15, linewidth = 1.2) +
  scale_color_manual(values = cols_gruppe) +
  annotate("text", x = 1.5, y = mean(daten_eb$M),
           label = "CIs überlappen sich\n≠ nicht signifikant!",
           size = 5, fontface = "bold", color = "grey30") +
  labs(title = "Konfidenzintervalle interpretieren",
       subtitle = "Überlappung ≠ Nicht-Signifikanz",
       x = "Gruppe", y = "Mittlerer WM-Score (95% CI)",
       color = "Gruppe") +
  theme_slide() +
  theme(legend.position = "none")
save_plot("S09_F12_ci_overlap.png", p_s09_f12)

# F14: Default ugly ggplot
p_s09_f14 <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot() +
  labs(title = "Default ggplot — reicht das für eine Publikation?")
save_plot("S09_F14_default_ugly.png", p_s09_f14)

# F15: Same plot in 4 themes
base_plot <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(x = "Gruppe", y = "WM-Score")

p_t1 <- base_plot + theme_gray(14) + labs(title = "theme_gray()")
p_t2 <- base_plot + theme_bw(14) + labs(title = "theme_bw()")
p_t3 <- base_plot + theme_minimal(14) + labs(title = "theme_minimal()")
p_t4 <- base_plot + theme_classic(14) + labs(title = "theme_classic()")

p_s09_f15 <- (p_t1 + p_t2) / (p_t3 + p_t4) +
  plot_annotation(title = "Themes: Gleicher Inhalt, anderes Erscheinungsbild",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S09_F15_themes.png", p_s09_f15)

# F16: Before/after labels
p_before <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Vorher: Rohvariablennamen") +
  theme_minimal(14)

p_after <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "Nachher: Klare Beschriftung",
       x = "Versuchsgruppe",
       y = "Working-Memory-Score (Punkte)",
       caption = "Daten: WM-Studie 2024") +
  theme_minimal(14)

p_s09_f16 <- p_before + p_after +
  plot_annotation(title = "labs(): Beschriftung macht den Unterschied",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S09_F16_labels.png", p_s09_f16)

# F17: Patchwork layouts
p_a <- ggplot(daten, aes(x = wm_score)) +
  geom_histogram(bins = 15, fill = col_kg, color = "white") +
  labs(title = "A: Histogramm", x = "WM-Score", y = "Häufigkeit") +
  theme_slide(12)

p_b <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "B: Boxplot", x = "Gruppe", y = "WM-Score") +
  theme_slide(12)

p_c <- ggplot(daten, aes(x = age, y = wm_score)) +
  geom_point(alpha = 0.4, color = col_kg) +
  geom_smooth(method = "lm", se = FALSE, color = col_eg) +
  labs(title = "C: Scatter", x = "Alter", y = "WM-Score") +
  theme_slide(12)

p_s09_f17 <- (p_a | p_b) / p_c +
  plot_annotation(
    title = "patchwork: Mehrere Plots kombinieren",
    subtitle = "(p_a | p_b) / p_c",
    theme = theme(plot.title = element_text(face = "bold", size = 20),
                  plot.subtitle = element_text(family = "mono", size = 14)))
save_plot("S09_F17_patchwork.png", p_s09_f17)


# =============================================================================
# S11 — ANOVA (3 plots)
# =============================================================================
cat("\n--- S11 Plots ---\n")

# F08: KG vs EG boxplots with overlap
p_s11_f08 <- ggplot(daten, aes(x = gruppe, y = wm_score, fill = gruppe)) +
  geom_boxplot(alpha = 0.7, show.legend = FALSE) +
  geom_jitter(alpha = 0.2, width = 0.15, size = 1.5) +
  scale_fill_manual(values = cols_gruppe) +
  labs(title = "WM-Score nach Gruppe",
       subtitle = "Die Mittelwerte unterscheiden sich — aber die Streuung ist gross",
       x = "Versuchsgruppe", y = "WM-Score (Punkte)") +
  theme_slide()
save_plot("S11_F08_boxplots_gruppen.png", p_s11_f08)

# F10: F-distribution with shaded p-area
f_obs <- 8.42  # example F from Folieninhalte
df1 <- 1; df2 <- 98
x_f <- seq(0, 15, length.out = 500)
f_df <- tibble(x = x_f, y = df(x, df1, df2))

p_s11_f10 <- ggplot(f_df, aes(x, y)) +
  geom_line(linewidth = 1) +
  geom_area(data = filter(f_df, x >= f_obs), alpha = 0.4, fill = col_eg) +
  geom_vline(xintercept = f_obs, linewidth = 1, linetype = "dashed", color = col_eg) +
  annotate("text", x = f_obs + 0.5, y = 0.15,
           label = paste0("F = ", f_obs), color = col_eg,
           fontface = "bold", size = 6, hjust = 0) +
  annotate("text", x = f_obs + 2, y = 0.05,
           label = "p = .004", color = col_eg, size = 5, hjust = 0) +
  labs(title = "F-Verteilung",
       subtitle = paste0("df1 = ", df1, ", df2 = ", df2,
                         " — schraffierter Bereich = p-Wert"),
       x = "F-Wert", y = "Dichte") +
  theme_slide()
save_plot("S11_F10_f_verteilung.png", p_s11_f10)

# F15: QQ-plots — good vs. problematic
set.seed(123)
good_resid <- rnorm(100)
bad_resid <- c(rnorm(80), rexp(20, 0.5) + 2)

qq_good <- tibble(
  theoretical = qnorm(ppoints(100)),
  sample = sort(good_resid)
)
qq_bad <- tibble(
  theoretical = qnorm(ppoints(100)),
  sample = sort(bad_resid)
)

p_qq_good <- ggplot(qq_good, aes(theoretical, sample)) +
  geom_point(color = col_kg, alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = col_eg, linewidth = 1) +
  labs(title = "Gut: Punkte auf der Linie",
       x = "Theoretische Quantile", y = "Beobachtete Quantile") +
  theme_slide(14)

p_qq_bad <- ggplot(qq_bad, aes(theoretical, sample)) +
  geom_point(color = col_kg, alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = col_eg, linewidth = 1) +
  labs(title = "Problematisch: Abweichung oben rechts",
       x = "Theoretische Quantile", y = "Beobachtete Quantile") +
  theme_slide(14)

p_s11_f15 <- p_qq_good + p_qq_bad +
  plot_annotation(title = "QQ-Plot: Normalverteilung prüfen",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S11_F15_qq_plots.png", p_s11_f15)


# =============================================================================
# S12 — Regression (4 plots)
# =============================================================================
cat("\n--- S12 Plots ---\n")

# F09: Scatterplot with regression line, labeled b0/b1/residual
mod_simple <- lm(wm_score ~ age, data = daten)
b0 <- coef(mod_simple)[1]
b1 <- coef(mod_simple)[2]

# Pick a point with visible residual
example_idx <- which.max(abs(residuals(mod_simple)))[1]
ex_x <- daten$age[example_idx]
ex_y <- daten$wm_score[example_idx]
ex_pred <- predict(mod_simple, newdata = tibble(age = ex_x))

p_s12_f09 <- ggplot(daten, aes(x = age, y = wm_score)) +
  geom_point(alpha = 0.4, color = col_kg, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = col_eg, linewidth = 1.2) +
  # b0 annotation
  annotate("point", x = 0, y = b0, color = "black", size = 0) +
  annotate("text", x = min(daten$age, na.rm = TRUE) + 1,
           y = predict(mod_simple, newdata = tibble(age = min(daten$age, na.rm = TRUE))) - 3,
           label = paste0("b\u2080 = ", round(b0, 1)),
           color = "black", fontface = "bold", size = 5, hjust = 0) +
  # b1 annotation (slope triangle)
  annotate("segment", x = 25, xend = 30, y = predict(mod_simple, newdata = tibble(age = 25)),
           yend = predict(mod_simple, newdata = tibble(age = 25)),
           linewidth = 0.8, linetype = "dotted") +
  annotate("segment", x = 30, xend = 30, y = predict(mod_simple, newdata = tibble(age = 25)),
           yend = predict(mod_simple, newdata = tibble(age = 30)),
           linewidth = 0.8, linetype = "dotted") +
  annotate("text", x = 31, y = mean(c(predict(mod_simple, newdata = tibble(age = 25)),
                                        predict(mod_simple, newdata = tibble(age = 30)))),
           label = paste0("b\u2081 = ", round(b1, 2)), fontface = "bold", size = 5, hjust = 0) +
  # Residual annotation
  annotate("segment", x = ex_x, xend = ex_x, y = ex_y, yend = ex_pred,
           color = "grey40", linewidth = 0.8, linetype = "dashed") +
  annotate("text", x = ex_x + 0.5, y = mean(c(ex_y, ex_pred)),
           label = "Residuum (e)", size = 4.5, hjust = 0, color = "grey30") +
  labs(title = "Regressionsgleichung: y = b\u2080 + b\u2081 \u00b7 x + e",
       subtitle = paste0("b\u2080 = ", round(b0, 1), ", b\u2081 = ", round(b1, 2),
                          " (pro Lebensjahr)"),
       x = "Alter (Jahre)", y = "WM-Score (Punkte)") +
  theme_slide()
save_plot("S12_F09_regression_linie.png", p_s12_f09)

# F12: 2x2 diagnostic plots (good vs. problematic)
set.seed(42)
n_diag <- 100
good_x <- rnorm(n_diag, 30, 8)
good_y <- 20 + 0.8 * good_x + rnorm(n_diag, 0, 5)
mod_good <- lm(good_y ~ good_x)

bad_x <- rnorm(n_diag, 30, 8)
bad_y <- 20 + 0.05 * bad_x^2 + rnorm(n_diag, 0, 2) * abs(bad_x - 30)
mod_bad <- lm(bad_y ~ bad_x)

diag_good <- tibble(
  fitted = fitted(mod_good),
  resid = residuals(mod_good),
  std_resid = rstandard(mod_good)
)
diag_bad <- tibble(
  fitted = fitted(mod_bad),
  resid = residuals(mod_bad),
  std_resid = rstandard(mod_bad)
)

p_rv_good <- ggplot(diag_good, aes(fitted, resid)) +
  geom_point(alpha = 0.5, color = col_kg) +
  geom_hline(yintercept = 0, color = col_eg, linetype = "dashed") +
  geom_smooth(se = FALSE, color = col_eg, linewidth = 0.8) +
  labs(title = "Gut: Kein Muster", x = "Fitted", y = "Residuen") +
  theme_slide(12)

p_rv_bad <- ggplot(diag_bad, aes(fitted, resid)) +
  geom_point(alpha = 0.5, color = col_kg) +
  geom_hline(yintercept = 0, color = col_eg, linetype = "dashed") +
  geom_smooth(se = FALSE, color = col_eg, linewidth = 0.8) +
  labs(title = "Problematisch: Trichterform", x = "Fitted", y = "Residuen") +
  theme_slide(12)

qq_diag_good <- tibble(
  theoretical = qnorm(ppoints(n_diag)),
  sample = sort(diag_good$std_resid)
)
qq_diag_bad <- tibble(
  theoretical = qnorm(ppoints(n_diag)),
  sample = sort(diag_bad$std_resid)
)

p_qq_diag_good <- ggplot(qq_diag_good, aes(theoretical, sample)) +
  geom_point(alpha = 0.5, color = col_kg) +
  geom_abline(color = col_eg, linewidth = 0.8) +
  labs(title = "Gut: Normalverteilt", x = "Theor. Quantile", y = "Std. Residuen") +
  theme_slide(12)

p_qq_diag_bad <- ggplot(qq_diag_bad, aes(theoretical, sample)) +
  geom_point(alpha = 0.5, color = col_kg) +
  geom_abline(color = col_eg, linewidth = 0.8) +
  labs(title = "Problematisch: Schwere Ränder", x = "Theor. Quantile", y = "Std. Residuen") +
  theme_slide(12)

p_s12_f12 <- (p_rv_good + p_rv_bad) / (p_qq_diag_good + p_qq_diag_bad) +
  plot_annotation(title = "Residualdiagnostik: Gut vs. Problematisch",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S12_F12_diagnostik.png", p_s12_f12)

# F14: Moderation — 2 regression lines with different slopes
p_s12_f14 <- ggplot(daten, aes(x = age, y = wm_score, color = gruppe)) +
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = cols_gruppe) +
  labs(title = "Moderation: Hängt der Alterseffekt von der Gruppe ab?",
       subtitle = "Verschiedene Steigungen → Interaktion",
       x = "Alter (Jahre)", y = "WM-Score (Punkte)",
       color = "Gruppe") +
  theme_slide()
save_plot("S12_F14_moderation.png", p_s12_f14)

# F16: Interaction — parallel vs non-parallel lines
# Simulated data for clear illustration
set.seed(99)
n_int <- 200
int_data <- tibble(
  age = rep(runif(n_int / 2, 18, 40), 2),
  gruppe = rep(c("KG", "EG"), each = n_int / 2)
) |>
  mutate(
    # Parallel: same slope, different intercept
    wm_parallel = ifelse(gruppe == "KG",
                         30 + 0.6 * age + rnorm(n(), 0, 5),
                         40 + 0.6 * age + rnorm(n(), 0, 5)),
    # Interaction: different slopes
    wm_interaction = ifelse(gruppe == "KG",
                            30 + 0.3 * age + rnorm(n(), 0, 5),
                            25 + 1.0 * age + rnorm(n(), 0, 5))
  )

p_parallel <- ggplot(int_data, aes(x = age, y = wm_parallel, color = gruppe)) +
  geom_point(alpha = 0.2, size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = cols_gruppe) +
  labs(title = "Keine Interaktion",
       subtitle = "Parallele Linien: gleiche Steigung",
       x = "Alter", y = "WM-Score", color = "Gruppe") +
  theme_slide(14) +
  theme(legend.position = "bottom")

p_interaction <- ggplot(int_data, aes(x = age, y = wm_interaction, color = gruppe)) +
  geom_point(alpha = 0.2, size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = cols_gruppe) +
  labs(title = "Interaktion",
       subtitle = "Nicht-parallele Linien: verschiedene Steigungen",
       x = "Alter", y = "WM-Score", color = "Gruppe") +
  theme_slide(14) +
  theme(legend.position = "bottom")

p_s12_f16 <- p_parallel + p_interaction +
  plot_annotation(title = "Interaktion erkennen: Sind die Linien parallel?",
                  theme = theme(plot.title = element_text(face = "bold", size = 20)))
save_plot("S12_F16_interaktion.png", p_s12_f16)


cat("\n=== All plots generated! ===\n")
cat("Output directory:", output_dir, "\n")
cat("Files:\n")
cat(paste(" ", list.files(output_dir, pattern = "*.png"), collapse = "\n"), "\n")
