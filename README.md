# text-sparring

> Ein harness-agnostischer Skill für **dialektisches Text-Sparring** zwischen zwei AI-Agenten.

Zwei AI-Agenten verbessern einen Text gemeinsam über 10 Runden, indem sie sich gegenseitig schärfen — wie Sparringspartner im Training. Welche Tools diese Agenten ausführen, ist zweitrangig: Entscheidend ist, dass mindestens ein Agent Dateien im Projektverzeichnis lesen und schreiben kann. Es geht nicht ums Gewinnen; es geht um akkumulierte Qualität durch Widerspruch und Integration.

## Wie es funktioniert

Jede Runde besteht aus drei Schritten:

1. **These** — Ein Agent produziert die bestmögliche Version des Texts.
2. **Antithese** — Der andere Agent stellt die fundamentalsten Annahmen radikal in Frage.
3. **Synthese** — Ein Agent integriert beide Sichten zu einer neuen Version (keine Kompromisse, echte Integration).

Die Synthese einer Runde wird zum Ausgangsartefakt der nächsten Runde. Nach 10 Runden endet das Sparring; das Ergebnis liegt in `FINAL_ARTIFACT.md`.

**Vollrotation**: Über die 10 Runden übernimmt jeder Agent jede Rolle (These / Antithese / Synthese) genau 5×. Die Verteilung ist deterministisch und ausbalanciert.

## Was das Besondere ist

- **Harness-agnostisch**: Funktioniert mit lokalen Agenten, die Dateizugriff haben, und semi-manuell auch mit webbasierten Chat-Tools.
- **Kein externer Daemon**: Kein `fswatch`, kein `cron`, kein `launchd`. Pures Bash + Markdown.
- **Self-polling Agents**: Nach jedem erledigten Schritt geht der Agent in einen blockierenden Bash-Loop (`watch_loop.sh`), prüft alle 30 Sekunden `state.md` und übernimmt automatisch, sobald er wieder dran ist.
- **Nur zwei manuelle Starts nötig**: einmal im initiierenden Tool ("Setup Sparring"), einmal im zweiten Tool ("Steig ein"). Danach läuft der Wechsel automatisch bis Runde 10.

## Architektur

```
dein-projekt/
├── <tool-instructions>                ← optional: Tool-spezifische Startanweisung
└── sparring/
    ├── CHALLENGE.md                   ← Regelwerk + Rotationsplan
    ├── state.md                       ← Aktueller Status (einzige Wahrheit)
    ├── watch_loop.sh                  ← Pure-Bash Polling
    ├── chatgpt_codex_instructions.md  ← Beispiel-Anweisung für einen zweiten Agent
    └── rounds/
        ├── round_01/
        │   ├── artifact.md            ← Ausgangstext
        │   ├── step_1_thesis.md
        │   ├── step_2_antithesis.md
        │   └── step_3_synthesis.md    ← wird zu artifact.md der Folgerunde
        ├── round_02/...
        └── round_10/...
```

## Installation

### Als Skill-Bundle

1. Lade das gepackte Bundle: [`dist/text-sparring.skill`](dist/text-sparring.skill)
2. Importiere es in eine Skill-fähige Agent-Umgebung.
3. Starte das Sparring in einem Projekt, auf dessen Dateien der Agent zugreifen darf.

### Direkt aus dem Source-Verzeichnis

Falls du den Skill direkt von der Quelle nutzen oder anpassen willst:

```bash
git clone <repo-url>
cd text-sparring
# Verwende das text-sparring/ Verzeichnis direkt als Skill-Pfad
```

## Nutzung

### Erstes Tool starten (Initiator)

```
Du in Agent A: "Starte ein Text-Sparring über draft.md"
```

Agent A:
- Fragt nach: zweiter Agent (Name + Tool), dein Name im Sparring
- Legt `sparring/` an und erzeugt die Projektdateien für das Sparring
- Ergänzt, falls passend, eine Tool-spezifische Startanweisung
- Erledigt **Schritt 1 (These) in Runde 1**
- Geht in den Wait-Loop

### Zweites Tool starten

Wechsle zu Agent B im selben Projektverzeichnis. Das kann ein zweiter lokaler Agent sein oder ein webbasiertes Chat-Tool, sofern du die Dateien manuell überträgst.

```
Du in Agent B: "Steig ins Sparring ein"
```

Agent B:
- Liest `sparring/state.md`
- Erledigt **Schritt 2 (Antithese) in Runde 1**
- Geht in den Wait-Loop

Ab jetzt läuft alles autonom. Beide Sessions wachen abwechselnd auf, erledigen ihre Schritte, gehen wieder schlafen — bis Runde 10 abgeschlossen ist.

## Trigger-Phrasen

Der Skill triggert auf eine breite Palette von Formulierungen:

**DE**: `Text-Sparring starten`, `lass zwei Agenten meinen Text schärfen`, `dialektischer Loop`, `Steig ins Sparring ein`, `Multi-Agent-Refinement`

**EN**: `set up a text sparring`, `let two agents spar on this`, `join the running sparring`

## Konfiguration

Standard-Werte im Skill (können in `state.md` pro Projekt überschrieben werden):

| Parameter | Default | Beschreibung |
|-----------|---------|--------------|
| `POLL_SEC` | `30` | Wie oft `watch_loop.sh` `state.md` prüft (Sekunden) |
| `MAX_WAIT_MIN` | `30` | Max. Wartezeit bevor Timeout-Alarm |
| Anzahl Runden | `10` | Fest in Rotationsplan, nicht parametrisiert |

## Voraussetzungen

- **macOS oder Linux** mit bash und `grep`/`sleep` (überall Standard)
- Für den autonomen Modus: zwei lokale Agent-Sessions mit Zugriff auf dasselbe Projektverzeichnis
- Für den semi-manuellen Modus: ein zweites Chat-Tool ohne Dateizugriff, bei dem du `state.md`, `CHALLENGE.md` und die relevanten Runden-Dateien manuell übergibst

Keine zusätzlichen Tools nötig. Keine Python-Dependencies. Kein `brew install`.

## Erweiterungs-Ideen

Aktuell fokussiert auf **Texte**. Mögliche Erweiterungen:

- **Code-Sparring**: Rollen-Definitionen für Refactoring-Reviews
- **Image-Prompt-Sparring**: Iterative Verbesserung von Bildgenerierungs-Prompts
- **Variable Rundenzahl**: 5 / 10 / 20 als Skill-Parameter
- **Intelligentes Exit-Kriterium**: Stopp wenn Antithese keinen substanziellen Punkt mehr findet

## Lizenz

[MIT](LICENSE) — siehe Lizenz-Datei.

## Hintergrund

Inspiriert von:

- **Hegel'schem Dreischritt** (These → Antithese → Synthese)
- **Reflexion** (Shinn et al., 2023) und **Self-Refinement** (Madaan et al., 2023)
- **Multi-Agent Debate** Mustern aus Frameworks wie AutoGen, LangGraph, CrewAI

Unterschied zu klassischen Multi-Agent-Frameworks: Dieser Skill braucht **keine** dedizierte Orchestrator-Software. Der "Orchestrator" sind die Agenten selbst, koordiniert über Markdown-Dateien auf dem Dateisystem. Das macht ihn portabel, transparent und debugbar.
