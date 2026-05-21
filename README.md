# text-sparring

> Ein harness-agnostischer Skill für **dialektisches Text-Sparring** zwischen zwei AI-Agenten.

Zwei AI-Agenten verbessern ein Artefakt gemeinsam über eine wählbare Anzahl von Runden, indem sie sich gegenseitig schärfen — wie Sparringspartner im Training. Welche Tools diese Agenten ausführen, ist zweitrangig: Entscheidend ist, dass mindestens ein Agent Dateien im Projektverzeichnis lesen und schreiben kann. Es geht nicht ums Gewinnen; es geht um akkumulierte Qualität durch Widerspruch und Integration.

## Wie es funktioniert

Jede Runde besteht aus drei Schritten:

1. **These** — Ein Agent produziert die bestmögliche Version des Texts.
2. **Antithese** — Der andere Agent stellt die fundamentalsten Annahmen radikal in Frage.
3. **Synthese** — Ein Agent integriert beide Sichten zu einer neuen Version (keine Kompromisse, echte Integration).

Die Synthese einer Runde wird zum Ausgangsartefakt der nächsten Runde. Nach der gewählten letzten Runde endet das Sparring; das Ergebnis liegt in `FINAL_ARTIFACT.md` beziehungsweise `FINAL_ARTIFACT/`.

**Rotation**: Der Skill nutzt ein deterministisches 10-Runden-Muster. Wenn weniger Runden gewählt werden, wird nur der entsprechende Präfix genutzt. Bei 10 Runden ist die Rollenverteilung exakt ausbalanciert.

**Artefakt statt ganzes Projekt**: Beim Start gibst du einen Pfad zu einer Datei oder einem Verzeichnis an. Nur dieses Artefakt wird über die Runden fortgeschrieben; der übrige Projektkontext dient zur Orientierung.

**Sparring-Typ**: Standard ist `Auto`. Der Skill leitet dann aus Artefakt und Projektkontext ab, ob eher `Text`, `Campaign`, `Skill` oder `Code` gechallenged wird. Du kannst den Typ bei der Initialisierung auch explizit setzen.

**Übergabeimpulse**: Jeder Schritt erzeugt neben seinem Hauptoutput eine kurze `*_handoff.md`-Datei. Darin markiert der aktuelle Agent 1–3 konkrete Prüf- oder Schärfpunkte für den nächsten Agenten. Die Haupttexte bleiben dadurch sauber, während der nächste Schritt trotzdem gezielter an Spannung, Risiko oder ungenutztem Potenzial weiterarbeiten kann.

**Subagent-Modus**: Für lange Sparrings ist ein isolierter Step-Kontext empfohlen. Die Hauptsession orchestriert nur noch: Sie liest `state.md`, erzeugt einen kleinen Prompt unter `sparring/context/`, delegiert den aktuellen Schritt an einen frischen Subagent/Worker/Workstream, prüft die erwarteten Output-Dateien und aktualisiert danach `state.md`.

**Subagent-Qualität**: Default ist `Inherit`. Der Skill setzt damit keine expliziten Modell- oder Reasoning-Overrides, sondern übernimmt die Qualität der Hauptsession. Optional kannst du `Balanced`, `High` oder `Role-based` wählen, sofern dein Tool solche Einstellungen unterstützt.

**Silent Wait Mode**: Während ein Agent im Wait-Loop ist, bleibt er stumm. Er schreibt keine Zwischenberichte oder Spekulationen, sondern reagiert erst wieder auf WAKE, DONE oder TIMEOUT.

**Resume nach Context-Limit**: Wenn eine Session abbricht oder der Chatverlauf verloren geht, reicht ein kurzer Prompt wie `Resume Sparring`. Der Agent liest `sparring/*/state.md`, erkennt den aktiven Lauf und setzt genau am nächsten Schritt fort oder startet wieder den Wait-Loop. Bei mehreren aktiven Läufen fragt er nach dem Namen.

**Pre-Check-Modus**: Vor dem INIT kannst du das Artefakt auf Sparring-Eignung prüfen lassen. Der Skill bewertet drei Dimensionen (Headroom, Konfliktfläche, Zielklarheit) auf einer 0/1/2-Skala (Max-Score 6/6) und empfiehlt 0–10 Runden, gedeckelt durch einen Größen-Cap. Absolute Vetos (kein lesbares Artefakt, kein Zielzustand erkennbar) führen zur Empfehlung 0 Runden. Der Turbo-Modus liest die Pre-Check-Empfehlung als Default für die Rundenzahl ein.

**Opt-in Qualitätsmessung (separater Skill)**: Die optionale dialektische Qualitätsmessung lebt im Sibling-Skill **`text-sparring-measurement`** (eigenes Bundle in `dist/text-sparring-measurement.skill`). Wenn aktiviert, erzeugt ein Evaluator-Subagent nach jedem Schritt Messdaten in `MEASUREMENT.md`. Vier rubrikspezifische Profile je nach Sparring-Typ (Text, Campaign, Skill, Code), 5 Dimensionen pro Profil auf 1–5-Skala. Baseline am Artefaktstart, Round-Delta pro Runde, kumulative Kurve am Ende. Default: ausgeschaltet. Wer Sparring ohne Messung will, braucht den Measurement-Skill nicht zu installieren.

## Was das Besondere ist

- **Harness-agnostisch**: Funktioniert mit lokalen Agenten, die Dateizugriff haben, und semi-manuell auch mit webbasierten Chat-Tools.
- **Kein externer Daemon**: Kein `fswatch`, kein `cron`, kein `launchd`. Pures Bash + Markdown.
- **Self-polling Agents**: Nach jedem erledigten Schritt geht der Agent in einen blockierenden Bash-Loop (`watch_loop.sh`), prüft alle 30 Sekunden `state.md` und übernimmt automatisch, sobald er wieder dran ist.
- **Stummes Warten**: Der Wait-Loop erzeugt keine laufenden UI-Kommentare. Das spart Tokens und hält die Hauptsession sauber.
- **Minimal ein manueller Start nötig**: Im `VollAutoSubagent`-Modus reicht ein einziger Start — der INIT-Agent orchestriert beide Rollen als Subagenten bis zum Finalartefakt. Im `Subagent`-Modus sind zwei Starts nötig (einmal pro Agent); danach läuft der Wechsel automatisch via Watch-Loop.

## Architektur

Mehrere Sparrings im selben Projekt sind möglich. Sie liegen als benannte Unterordner im gemeinsamen `sparring/`-Container:

```
dein-projekt/
├── <tool-instructions>                ← optional: Tool-spezifische Startanweisung
└── sparring/
    ├── readme-v1/                     ← abgeschlossenes Sparring (FINAL_ARTIFACT vorhanden)
    │   └── ...
    └── readme-v2/                     ← laufendes Sparring
        ├── artifact.md                ← stabile Definition des gechallengten Artefakts
        ├── CHALLENGE.md               ← Regelwerk + Rotationsplan
        ├── state.md                   ← Aktueller Status (einzige Wahrheit)
        ├── watch_loop.sh              ← Pure-Bash Polling
        ├── chatgpt_codex_instructions.md ← Beispiel-Anweisung für einen zweiten Agent
        ├── context/                   ← isolierte Step-Kontexte für Subagent-Ausführung
        ├── FINAL_ARTIFACT.md|/        ← nach Abschluss der letzten Runde
        └── rounds/
            ├── round_01/
            │   ├── artifact.md|artifact/  ← Ausgangsartefakt
            │   ├── step_1_thesis.md|/
            │   ├── step_1_handoff.md
            │   ├── step_2_antithesis.md
            │   ├── step_2_handoff.md
            │   ├── step_3_synthesis.md|/  ← wird zum Artefakt der Folgerunde
            │   └── step_3_handoff.md
            ├── round_02/...
            └── round_NN/...
```

Der Sparring-Name wird im INIT-Interview gewählt und in `state.md` als `Sparring-Name` festgehalten. Bei mehreren aktiven Sparrings erkennt der JOIN-Modus automatisch das gemeinte; ist es mehrdeutig, fragt der Skill nach.

Ein neues Sparring darf parallel zu bestehenden laufenden oder abgeschlossenen Sparrings starten. Start-Phrasen wie `neues Sparring`, `Text-Sparring starten` oder `Auto-Sparring über ...` erzeugen immer einen neuen Lauf; vorhandene `sparring/*/state.md` dienen nur zur Orientierung und Namensvergabe. Wenn der gewünschte Name schon existiert, wählt der Skill automatisch den nächsten freien Slug (`-v2`, `-v3`, ...).

## Installation

### Als Skill-Bundle

1. Lade das Haupt-Bundle: [`dist/text-sparring.skill`](dist/text-sparring.skill)
2. Optional für Qualitätsmessung: [`dist/text-sparring-measurement.skill`](dist/text-sparring-measurement.skill) — eigenständig importierbar.
3. Importiere die Bundles in eine Skill-fähige Agent-Umgebung.
4. Starte das Sparring in einem Projekt, auf dessen Dateien der Agent zugreifen darf.

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
Du in Agent A: "Starte ein Text-Sparring über README.md"
```

Agent A:
- Stellt **fünf Pflichtfragen** (Artefakt, Sparring-Name, zweites Tool, Rundenzahl, Ausführungsmodus) und schlägt für jede einen konkreten Default vor
- Errät den Rest aus Projekt-Scan und Smart-Defaults (eigener Name, Sparring-Typ, Subagent-Qualität, Projektkontext-Dateien, Measurement) und zeigt ihn in der Zusammenfassung zur Bestätigung
- Legt `sparring/<NAME>/` an und erzeugt die Projektdateien für das Sparring
- Ergänzt, falls passend, eine Tool-spezifische Startanweisung
- Erledigt **Schritt 1 (These) in Runde 1** plus Übergabeimpuls
- Fährt je nach Ausführungsmodus fort: `VollAutoSubagent` orchestriert alle weiteren Schritte in derselben Session bis zum Finalartefakt; `Subagent` und `Inline` geben den Handover-Prompt aus und gehen danach in den Wait-Loop

### Zweites Tool starten

Wechsle zu Agent B im selben Projektverzeichnis. Das kann ein zweiter lokaler Agent sein oder ein webbasiertes Chat-Tool, sofern du die Dateien manuell überträgst.

```
Du in Agent B: "Steig ins Sparring ein"
# oder bei mehreren aktiven Sparrings:
Du in Agent B: "Steig ins Sparring readme-v2 ein"
```

Agent B:
- Erkennt das aktive Sparring (oder fragt bei Mehrdeutigkeit nach)
- Liest `sparring/<NAME>/state.md`
- Liest den Übergabeimpuls aus `step_1_handoff.md`
- Erledigt **Schritt 2 (Antithese) in Runde 1** plus Übergabeimpuls
- Geht in den Wait-Loop

Ab jetzt läuft alles autonom. Beide Sessions wachen abwechselnd auf, erledigen ihre Schritte, gehen wieder schlafen — bis die gewählte letzte Runde abgeschlossen ist.

### Mehrere Sparrings parallel oder nacheinander

Du kannst auf dasselbe Artefakt mehrere Sparrings legen (z. B. `readme-v1`, `readme-v2`) oder unterschiedliche Artefakte gleichzeitig sparren. Jedes Sparring lebt vollständig in seinem eigenen Unterordner, hat eigenen Watch-Loop, eigenen State und eigenes Finalartefakt. Mehrere Sparring-Snippets in derselben CLAUDE.md sind ausdrücklich erlaubt — sie unterscheiden sich über den `Sparring-Pfad`.

## Trigger-Phrasen

Der Skill triggert auf eine breite Palette von Formulierungen.

**Hauptskill `text-sparring`** (INIT + JOIN + RESUME):
- **DE**: `Text-Sparring starten`, `Auto-Sparring`, `Autosparring`, `Sparring über Dateien/Ordner`, `Resume Sparring`, `Sparring fortsetzen`, `Sparring wieder aufnehmen`, `lass zwei Agenten meinen Text schärfen`, `dialektischer Loop`, `Steig ins Sparring ein`, `Multi-Agent-Refinement`
- **EN**: `set up a text sparring`, `let two agents spar on this`, `resume sparring`, `continue sparring`, `join the running sparring`

**Turbo-Modus** (INIT ohne Interview): `Auto-Sparring`, `Autosparring`, `Turbo-Modus`, `Schnellstart`, `ohne Fragen`, `auto-init`, `auto init`, `quickstart`, `quick`

**Pre-Check**: `pre-check`, `sparring-check`, `lohnt sich das Sparring`, `sparring fit`, `vor dem Start prüfen`, `is this worth sparring`

**RESIZE** (laufendes oder abgeschlossenes Sparring verlängern/verkürzen): `verlängere Sparring <NAME> um X Runden`, `erweitere auf X Runden`, `extend by X`, `verkürze auf X Runden`, `kürze um X Runden`, `nach Runde X beenden`, `shorten to X`

**Sibling-Skill `text-sparring-measurement`** (optionale Qualitätsmessung — eigene Aktivierung, nicht der Hauptskill): `mit Messung`, `Messung einschalten`, `with measurement`, `measure quality`, `Baseline-Score`, `Round-Delta`, `dialektische Qualitätsmessung`

## Konfiguration

Standard-Werte im Skill (können in `state.md` pro Projekt überschrieben werden):

| Parameter | Default | Beschreibung |
|-----------|---------|--------------|
| `POLL_SEC` | `30` | Wie oft `watch_loop.sh` `state.md` prüft (Sekunden) |
| `MAX_WAIT_MIN` | `30` | Max. Wartezeit bevor Timeout-Alarm |
| Anzahl Runden | `10` | Wählbar von 1 bis 10 |
| `Sparring-Typ` | `Auto` | `Auto`, `Text`, `Campaign`, `Skill` oder `Code`; wird in `state.md` gespeichert |
| `Ausführungsmodus` | `Auto` | `Auto`, `VollAutoSubagent`, `Subagent` oder `Inline`; wird in `state.md` gespeichert |
| `Messung` | `Aus` | Opt-in Qualitätsmessung über den Sibling-Skill `text-sparring-measurement`: `Aus` oder `An`; Aktivierung per Trigger-Phrase oder explizit beim INIT |

### Artefakte

- `file`: Eine einzelne Datei wird nach `round_01/artifact.md` kopiert. These und Synthese sind ebenfalls Markdown-Dateien.
- `directory`: Ein Verzeichnis wird nach `round_01/artifact/` kopiert. These und Synthese sind vollständige Verzeichnisse (`step_1_thesis/`, `step_3_synthesis/`).

Der Skill speichert die stabile Artefaktdefinition in `sparring/artifact.md` und den laufenden Zustand in `sparring/state.md`.

Bei Directory-Artefakten bleibt die Antithese trotzdem immer eine Markdown-Datei (`step_2_antithesis.md`). Sie erzeugt keine neue Artefaktfassung, sondern strukturierte Kritik.

### Sparring-Typen

- `Auto`: Typ aus Artefakt und Projektkontext ableiten.
- `Text`: Generische Text-, README-, Essay- oder Konzeptarbeit.
- `Campaign`: Posts, Kampagnen, Content-Serien oder Redaktionsmaterial.
- `Skill`: Skills, Agent-Workflows, Prompt-/Template-Systeme oder `.skill`-Bundles.
- `Code`: Quellcode, Tests, Build-Dateien oder technische Implementierungen.

### Ausführungsmodi

- `VollAutoSubagent`: Ein INIT-Agent orchestriert **beide Rollen** vollautomatisch als Subagenten-Loop. Kein Handover, keine zweite Session, kein Wait-Loop. Empfohlen, wenn beide Agenten Claude sind und alles in einer Session laufen soll.
- `Auto`: Subagent-Ausführung verwenden, wenn das aktuelle Tool sie erkennbar unterstützt; sonst inline.
- `Subagent`: Zwei-Session-Architektur — jeder Agent führt seinen eigenen Schritt als Subagent aus; Koordination läuft via Watch-Loop und `state.md`. Wenn das Tool Subagents nicht kann, stoppt der Agent und fragt nach.
- `Inline`: Der aktive Agent erledigt seine Schritte direkt in der Hauptsession.

Kurzentscheidung:

| Situation | Empfohlener Modus |
|-----------|-------------------|
| Ein Claude-kompatibles Tool soll beide Rollen in einer Session bis zum Ende orchestrieren | `VollAutoSubagent` |
| Zwei lokale Agent-Sessions sollen sich autonom über Dateien abwechseln | `Subagent` |
| Das aktuelle Tool kann keine Subagents oder das Sparring soll bewusst direkt in der Hauptsession laufen | `Inline` |
| Unsicher, ob Subagents verfügbar sind | `Auto` |

### Subagent-Qualität

- `Inherit`: Keine explizite Modell-/Reasoning-Vorgabe; Subagent übernimmt die Hauptsession.
- `Balanced`: Mittlere Qualität/Kosten, wenn das Tool eine Wahl erlaubt.
- `High`: Stärkste sinnvoll verfügbare Qualität, wenn das Tool eine Wahl erlaubt.
- `Role-based`: These eher Balanced, Antithese und Synthese eher High.

## Voraussetzungen

- **macOS oder Linux** mit bash und `grep`/`sleep` (überall Standard)
- Für den autonomen Modus: zwei lokale Agent-Sessions mit Zugriff auf dasselbe Projektverzeichnis
- Für den semi-manuellen Modus: ein zweites Chat-Tool ohne Dateizugriff, bei dem du `state.md`, `CHALLENGE.md` und die relevanten Runden-Dateien manuell übergibst

Keine zusätzlichen Tools nötig. Keine Python-Dependencies. Kein `brew install`.

## Erweiterungs-Ideen

Mögliche Erweiterungen:

- **Image-Prompt-Sparring**: Iterative Verbesserung von Bildgenerierungs-Prompts
- **Erweiterte Rundenzahl**: 20+ Runden mit wiederholbarem oder neu balanciertem Rotationsplan
- **Intelligentes Exit-Kriterium**: Stopp wenn Antithese keinen substanziellen Punkt mehr findet

## Lizenz

[MIT](LICENSE) — siehe Lizenz-Datei.

## Hintergrund

Inspiriert von:

- **Hegel'schem Dreischritt** (These → Antithese → Synthese)
- **Reflexion** (Shinn et al., 2023) und **Self-Refinement** (Madaan et al., 2023)
- **Multi-Agent Debate** Mustern aus Frameworks wie AutoGen, LangGraph, CrewAI

Unterschied zu klassischen Multi-Agent-Frameworks: Dieser Skill braucht **keine** dedizierte Orchestrator-Software. Der "Orchestrator" sind die Agenten selbst, koordiniert über Markdown-Dateien auf dem Dateisystem. Das macht ihn portabel, transparent und debugbar.
