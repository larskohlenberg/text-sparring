# Changelog

Alle bemerkenswerten Änderungen werden hier dokumentiert.

Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/),
Versionierung nach [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **Auto-Sparring-Trigger gehärtet:** `Auto-Sparring`, `Autosparring` und `Sparring über Dateien/Ordner` sind jetzt explizite Hauptskill-Trigger. Der Skill verbietet bei angefordertem Sparring die Abkürzung in eine einzelne finale Analyse-Datei und muss stattdessen `sparring/<NAME>/` mit `state.md`, `CHALLENGE.md`, Rundenordnern, Handover und Wait-Loop anlegen.
- **Turbo-Erkennung entschärft:** Das generische Wort `auto` triggert nicht mehr den Turbo-Modus. Turbo hört jetzt auf explizite Phrasen wie `Auto-Sparring`, `Autosparring`, `auto-init`, `auto init`, `Turbo-Modus`, `Schnellstart`, `ohne Fragen`, `quickstart` oder `quick`.
- **Resume-Modus nach Context-Limit:** Kurze Prompts wie `Resume Sparring`, `Sparring fortsetzen` oder `Sparring wieder aufnehmen` rekonstruieren einen abgebrochenen Lauf aus `sparring/*/state.md` statt aus Chatverlauf. Bei genau einem aktiven Sparring setzt der Agent automatisch fort; bei Mehrdeutigkeit oder fehlenden Schrittdateien zeigt er eine knappe Recovery-Karte.
- **Neues Sparring trotz laufender Läufe:** Start-Phrasen für ein neues Sparring haben Vorrang vor JOIN/RESUME. Aktive `sparring/*/state.md` blockieren INIT/Turbo nicht mehr; Namenskollisionen werden automatisch als `-v2`, `-v3`, ... aufgelöst.

### Changed (Simplification Pass)
- **SKILL.md auf Kern-Workflow eingedampft** (525 → 275 Zeilen, ~48 % weniger). Detail-Sektionen leben jetzt in `text-sparring/references/` (Pre-Check, Turbo, RESIZE, Gates, Conventions) und werden bei Bedarf gelesen. Lädt damit beim Triggern ein deutlich kleineres Stück Kontext.
- **Description radikal gekürzt** (~1100 → ~360 Zeichen, ein Satz Deutsch + Trigger-Phrasen + Negativbeispiel). Lange Descriptions verschlechtern Trigger-Genauigkeit eher als sie zu verbessern.
- **Interview von 10 auf 5 Pflichtfragen reduziert** (Artefakt, Sparring-Name, zweites Tool, Rundenzahl, Ausführungsmodus). Der Rest (eigener Name, Sparring-Typ, Subagent-Qualität, Measurement, Projektkontext-Dateien) wird aus Smart-Defaults und Projekt-Scan abgeleitet und in der finalen Konfigurations-Zusammenfassung zur Bestätigung präsentiert.
- **RESIZE-Modus von 58 auf ~15 Zeilen geschrumpft.** Sechs-Schritt-Choreografie zu 5 nummerierten Punkten zusammengezogen.
- **Single-Skill-Modus durch Worker-Mode-Framing ersetzt.** Statt andere Skills (brainstorming, TDD, systematic-debugging) per Verbot auszusperren, erklärt der Skill jetzt, dass jeder Sparring-Step Worker-Mode mit fertiger Rolle und vorgegebenen Output-Pfaden ist — andere Skills sind dann nicht der Konflikt, sondern nur ein Mismatch ihrer Trigger-Logik mit dieser Step-Natur.

### Removed
- **Measurement als integrierter Bestandteil**: alle Measurement-Files (Rubrics, Context-Template, Procedure-Beschreibung) sind in den neuen Sibling-Skill `text-sparring-measurement` ausgelagert. Hauptskill ist measurement-frei; bei `Measurement: on` in `state.md` verweist er per Pointer auf den Sibling. Wer Sparring ohne Messung will, braucht den Measurement-Skill nicht.

### Added
- **`text-sparring-measurement` als eigenständiger Sibling-Skill** (`dist/text-sparring-measurement.skill`, 25 KB). Eigene Frontmatter, eigene Trigger-Logik ("mit Messung", "with measurement", "Baseline-Score", "Round-Delta"). Enthält die 4 Rubrics (Text/Campaign/Skill/Code), den Evaluator-Kontext-Template und das MEASUREMENT-Layout.
- **`text-sparring/references/`** mit 5 Dateien: `gates.md`, `turbo.md`, `precheck.md`, `resize.md`, `conventions.md`. SKILL.md verlinkt sie als Pointer.

## [0.2.0] - 2026-05-16

### Added
- **Pre-Check-Modus (Sparring-Fit-Einschätzung vor dem Start):** Neuer Modus neben INIT, JOIN und RESIZE. Trigger-Phrasen wie *"pre-check"*, *"sparring-check"*, *"lohnt sich das Sparring"*, *"sparring fit"*, *"vor dem Start prüfen"* rufen einen Evaluator-Agenten auf, der das Artefakt auf Sparring-Eignung bewertet. Drei Dimensionen werden auf einer 1–5-Skala bewertet: **Headroom** (Ist noch Entwicklungspotenzial da?), **Konfliktfläche** (Gibt es angreifbare Stellen?), **Zielklarheit** (Ist der gewünschte Zielzustand klar genug?). Absolute Vetos (z. B. kein lesbares Artefakt, kein Projektkontext) stoppen mit Empfehlung 0 Runden. Ohne Veto ergibt sich eine Empfehlung von 1–10 Runden. Der Turbo-Modus liest das Pre-Check-Ergebnis (`precheck_rounds`) als Default für die Rundenzahl ein. Ergebnis wird als `MEASUREMENT.md`-Vorläufer in `sparring/` abgelegt, falls schon ein Sparring-Ordner existiert.
- **Opt-in dialektische Qualitätsmessung pro Runde:** Evaluator-Subagent nach jedem Schritt (Steps 2.5a und 2.5b) erzeugt Messdaten in `MEASUREMENT.md`. Vier Rubrik-Typen passend zum Sparring-Typ: **Text** (5 Dimensionen: Integrative Complexity, Argumentation, Idea Density, Klarheit, Constraint-Treue), **Campaign**, **Skill**, **Code** (je 5 Dimensionen auf 1–5-Skala). Baseline-Messung am Artefaktstart, Round-Delta nach jeder Runde, kumulative Gesamtkurve am Ende. Default: ausgeschaltet. Aktivierung im INIT-Interview oder per Trigger-Phrase *"mit Messung"*, *"Messung einschalten"*, *"measure quality"*.
- **RESIZE-Modus (Sparring verlängern oder verkürzen):** Neuer dritter Modus neben INIT und JOIN. Erweiterungs-Phrasen *"Verlängere Sparring readme-v1 um 3 Runden"*, *"erweitere auf 8 Runden"*, *"extend by 3"* hängen Runden an (max. 10 gesamt). Verkürzungs-Phrasen *"verkürze auf 5 Runden"*, *"kürze um 2 Runden"*, *"nach Runde 5 beenden"*, *"shorten to 5"* reduzieren die Gesamtrundenzahl (nur für laufende Sparrings; nie unter die aktuell laufende Runde). Erweiterung funktioniert für abgeschlossene und laufende Sparrings; bei abgeschlossenen wird `FINAL_ARTIFACT` als Snapshot zu `FINAL_ARTIFACT_after_round_N` archiviert, die letzte Synthese wird zum Artefakt der neuen Runde, und der Wait-Loop wird neu gestartet mit Handover-Prompt. Bei laufenden Sparrings reicht eine state.md-Anpassung; der bereits aktive Wait-Loop sieht das neue Total beim nächsten Rundenwechsel.
- **Projektkontext-Mechanik:** Während des INIT scannt der Agent das Projekt nach typischen Kontext-Dokumenten (Redaktionsplan, Style Guide, Briefing, Brand Voice, Tone of Voice, Content-Strategy, Personas, Messaging, Positioning, `CONTRIBUTING.md`) und schlägt sie als Projektkontext für das Sparring vor. Bestätigte Dateien werden als **referenzierte Pfade** in `artifact.md` unter `Projektkontext` eingetragen (nicht kopiert, damit Live-Updates am Redaktionsplan auch laufende Sparrings erreichen). Jede Rolle (These/Antithese/Synthese) liest diese Dateien vor ihrem Schritt und wendet Constraints daraus auf den Output an. Klausel in SKILL.md (Interview Frage 3, Scaffolding), CHALLENGE.md.tpl (Rollen-Header), step_context.md.tpl (Pflichtlektüre) und artifact.md.tpl (neue Projektkontext-Sektion) hinterlegt. Löst das Problem, dass Längen-Constraints aus Projekt-Dokumenten (z. B. LinkedIn-Postlänge im Redaktionsplan) bislang nicht zu den Agenten durchdrangen.
- **Verbot programmatischer Messung/Vergleiche während Step-Arbeit (sprachunabhängig):** Subagents und die Hauptsession im Inline-Modus dürfen keine Code-Ausführung zur Längen-Messung, Sektionsextraktion oder zum Vergleich von Outputs gegen Vorrunden bzw. Referenzdateien nutzen — egal in welcher Sprache. Das deckt Shell-Pipes (`wc`, `awk`, `grep`, `sed`, `tr`, `cut`, `head`, `tail`), `python3 -c`-One-Liner, Node-/Deno-Snippets und spontan angelegte Hilfsskripte gleichermaßen ab. Solche Aufrufe triggerten in der Praxis Sicherheitsabfragen der Harness und blockierten den Wait-Loop des aufrufenden Agenten — typischerweise ab Runde 4 bei Campaign-Sparrings. Erste Fassung deckte nur Shell ab; Agent wich anschließend auf Python aus, weshalb die Regel jetzt sprachunabhängig formuliert ist.
- **Single-Skill-Modus (Skill-Isolation):** Während eines laufenden Sparrings (INIT, JOIN, Step-Worker, Wait-Loop) werden keine anderen Skills automatisch aktiviert — auch keine, die sich aggressiv selbst triggern wie `using-superpowers`, `brainstorming`, `test-driven-development`, `systematic-debugging`, `writing-plans` etc. Das verhindert Workflow-Overkill (z. B. zusätzliche Brainstorming- oder TDD-Schleifen während einer Sparring-Runde). Ausnahme: explizite Skill-Nennung im User-Prompt. Klausel ist in SKILL.md, im Handover-Prompt, im CLAUDE.md-Snippet, im step_context-Template und in den ChatGPT/Codex-Instructions hinterlegt.
- **Copy-paste-fertiger Handover-Prompt am Ende der INIT-Phase.** Statt nur einer kurzen Anweisung *"sag dort: Steig ins Sparring ein"* gibt der Agent jetzt einen explizit abgegrenzten, vollständigen Prompt aus, der den Namen des zweiten Agenten, den Sparring-Namen, den Sparring-Pfad und die nötigen JOIN-Schritte enthält. Funktioniert sowohl im normalen Interview-Modus als auch im Turbo-Modus.
- **Turbo-Modus für INIT:** Trigger-Phrasen wie *"Turbo-Modus"*, *"Schnellstart"*, *"ohne Fragen"*, *"auto-init"* überspringen das komplette Interview. Der Agent generiert für alle 8 Punkte konkrete Vorschläge aus Projektkontext, fasst die Konfiguration in 4–6 Zeilen zusammen und legt direkt los. Einzelfragen werden nur gestellt, wenn kein vertretbarer Default ableitbar ist.
- **Aktive Interview-Vorschläge:** Das INIT-Interview erwartet jetzt pro Frage einen konkreten Vorschlag mit einer Satz-Begründung, basierend auf Projektkontext und Artefakt — nicht mehr nur statische Defaults. Am Ende fasst der Agent die gewählte Konfiguration zusammen und holt sich eine finale Bestätigung, bevor das Scaffolding entsteht.
- **Mehrere Sparrings pro Projekt:** Jedes Sparring lebt jetzt in einem benannten Unterordner `sparring/<NAME>/`. Mehrere Sparrings können parallel oder nacheinander im selben Projekt laufen — z. B. `sparring/readme-v1/` und `sparring/readme-v2/`.
- Neue Interview-Frage **"Wie soll dieses Sparring heißen?"** mit Default aus Artefakt-Basename und automatischer Versionierung (`-v2`, `-v3`) bei Namenskonflikten. Slugs werden normalisiert (Kleinbuchstaben, Ziffern, Bindestriche).
- Automatische **Erkennung des aktiven Sparrings im JOIN-Modus**: Bei genau einem aktiven Sparring silent join, bei mehreren Rückfrage, expliziter Name in der Trigger-Phrase wird übernommen.
- `Sparring-Name` und `Sparring-Pfad` als neue Felder in `state.md`, `CHALLENGE.md`, `step_context.md` und `claude_md_snippet.md`.
- `watch_loop.sh` lokalisiert seine `state.md` jetzt selbständig über das eigene Script-Verzeichnis — funktioniert in jedem Sparring-Unterordner ohne Argumente außer dem Agent-Namen.
- Vierter Gate **Execution Mode Gate**: Wenn `Ausführungsmodus: Subagent` gesetzt ist und kein Subagent gestartet werden kann, sofort stoppen und den User fragen. Kein stiller Fallback auf Inline.
- **Pflichtabschluss-Regel**: Nach jedem State-Update gibt es nur zwei gültige Endzustände — Watch-Loop starten oder finales Artefakt melden. Still-Fertig-Sein ist ein expliziter Fehler.
- Drei harte Gates (Role, Input, Output) am Anfang von `SKILL.md`, die vor jeder Schreibaktion geprüft werden — abgeleitet aus dem Sparring-Selbsttest (R3-Synthese), aber knapp gehalten statt als vollständiges Sicherheitsmanual.
- Default-Ausschlussliste für Directory-Artefakte (`sparring/`, `.git/`, `node_modules/`, `dist/`, `build/`, `.venv/`, `__pycache__/`, `.DS_Store`), damit Selbstreferenz- und Build-Müll nicht in den Sparring-Korpus rutschen.
- Eskalation auf explizite Include-Liste, wenn das Artefakt ein Projekt-Root mit vielen Top-Level-Einträgen ist.
- `Boundary`-Sektion in `templates/artifact.md.tpl` mit `Excluded-Pfade` und `Included-Pfade` zur Dokumentation der tatsächlich verwendeten Verzeichnisgrenzen.
- Separate `*_handoff.md`-Dateien pro Schritt, damit Agenten dem nächsten Schritt gezielte Prüf- und Schärfimpulse mitgeben können.

### Changed (Breaking)
- **Layout-Wechsel:** Sparrings leben jetzt unter `sparring/<NAME>/`, nicht mehr flach in `sparring/`. Bestehende `sparring/`-Verzeichnisse aus der v0.1.0-Ära müssen manuell umbenannt werden (z. B. `mv sparring sparring-legacy && mkdir sparring && mv sparring-legacy sparring/legacy`), damit der Skill sie weiterhin findet. Der `watch_loop.sh`-Aufruf verlangt jetzt den vollen Sparring-Pfad: `bash sparring/<NAME>/watch_loop.sh "<AgentName>"`.
- Initialer `Ausführungsmodus` (`Auto`, `Subagent`, `Inline`) mit gespeicherter tatsächlicher `Step-Ausführung` in `state.md`.
- `step_context.md.tpl` als Vorlage für isolierte Subagent-Step-Kontexte.
- Datei- oder Verzeichnis-Artefakte mit stabiler Definition in `sparring/artifact.md`.
- Initialer `Sparring-Typ` (`Auto`, `Text`, `Campaign`, `Skill`, `Code`) mit erkannter konkreter Ausprägung in `state.md`.
- Flexible Rundenzahl in der Initialisierung (1 bis 10, Default 10).
- Automatisches Warten im JOIN-Modus, wenn der bekannte andere Agent gerade dran ist.
- Initiale `Subagent-Qualität` (`Inherit`, `Balanced`, `High`, `Role-based`) mit tool-agnostischer Modell-/Reasoning-Policy.
- Klarstellung, dass Directory-Sparrings keine `step_2_antithesis/` erzeugen; die Antithese bleibt strukturierte Markdown-Kritik.
- Silent Wait Mode: Während `watch_loop.sh` läuft, geben Agenten keine Zwischenkommentare oder Statusmeldungen aus.

## [0.1.0] - 2026-05-12

### Added
- Initiale Implementierung des Text-Sparring Skills
- INIT- und JOIN-Modus für asymmetrische Startszenarien
- Vollrotations-Plan: 10 Runden mit ausbalancierten Rollen (5×5)
- `watch_loop.sh` als pures Bash-Polling ohne externe Tools
- Drei Exit-Codes: WAKE (0), DONE (1), TIMEOUT (2)
- Templates für CLAUDE.md-Integration und ChatGPT/Codex-Instructions
- Default-Konfiguration: 30s Polling, 30min Timeout, 10 Runden
- Gepacktes `.skill`-Bundle im `dist/`-Verzeichnis

### Notes
- Skill funktioniert vollautonom mit Claude Code + Codex CLI (Variante A)
- ChatGPT Web ist semi-manuell unterstützt (Variante B)
- Code-Sparring und Image-Prompt-Sparring sind als zukünftige Erweiterungen geplant
