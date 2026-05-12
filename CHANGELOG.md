# Changelog

Alle bemerkenswerten Änderungen werden hier dokumentiert.

Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/),
Versionierung nach [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Drei harte Gates (Role, Input, Output) am Anfang von `SKILL.md`, die vor jeder Schreibaktion geprüft werden — abgeleitet aus dem Sparring-Selbsttest (R3-Synthese), aber knapp gehalten statt als vollständiges Sicherheitsmanual.
- Default-Ausschlussliste für Directory-Artefakte (`sparring/`, `.git/`, `node_modules/`, `dist/`, `build/`, `.venv/`, `__pycache__/`, `.DS_Store`), damit Selbstreferenz- und Build-Müll nicht in den Sparring-Korpus rutschen.
- Eskalation auf explizite Include-Liste, wenn das Artefakt ein Projekt-Root mit vielen Top-Level-Einträgen ist.
- `Boundary`-Sektion in `templates/artifact.md.tpl` mit `Excluded-Pfade` und `Included-Pfade` zur Dokumentation der tatsächlich verwendeten Verzeichnisgrenzen.
- Separate `*_handoff.md`-Dateien pro Schritt, damit Agenten dem nächsten Schritt gezielte Prüf- und Schärfimpulse mitgeben können.
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
