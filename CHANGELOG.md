# Changelog

Alle bemerkenswerten Änderungen werden hier dokumentiert.

Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/),
Versionierung nach [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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
