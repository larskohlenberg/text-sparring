---
name: text-sparring
description: Setze ein dialektisches Text-Sparring zwischen zwei AI-Agenten auf oder steige in ein laufendes ein — These → Antithese → Synthese über mehrere Runden. Triggert auf "starte ein Text-Sparring", "lass zwei Agenten meinen Text schärfen", "steig ins Sparring ein", "Multi-Agent-Refinement", sowie auf Turbo-, Pre-Check- und Resize-Varianten. Nicht für einfache Reviews oder Proofreading.
---

# Text Sparring

Ein harness-agnostischer Skill zum Aufsetzen und Mitwirken an einem **Text-Sparring zwischen zwei AI-Agenten**. Zwei Agenten durchlaufen eine konfigurierbare Anzahl von Runden mit den Rollen **These → Antithese → Synthese**.

Es geht **nicht ums Gewinnen**, sondern um gegenseitiges Schärfen — wie zwei Sparringspartner im Training. Der Skill kennt keinen Inhalt; er orchestriert nur den **Prozess**. Der zu sparrende Text liegt außerhalb des Skills im Projektverzeichnis.

## Was diese Skill ist (und was nicht)

Diese Skill ist **Prozess-Orchestrierung**, keine kreative Exploration. Die Arbeit pro Aktivierung ist immer dasselbe enge Muster: lies `state.md`, erledige genau einen Schritt nach Rollen-Definition aus `CHALLENGE.md`, aktualisiere `state.md`, zurück in den Wait-Loop. Es gibt nichts zu brainstormen, nichts zu planen, nichts zu debuggen — der Plan steht in `state.md`, die Rolle steht in `CHALLENGE.md`, der Output-Pfad steht im Step-Kontext.

Wenn andere Workflow-Skills (brainstorming, TDD, systematic-debugging, writing-plans usw.) sich beim Lesen der User-Phrase aufdrängen: das ist ein Mismatch zwischen ihrer Trigger-Logik und der Worker-Natur dieses Schritts. Folge dem Sparring-Workflow; andere Skills nur dann hinzuziehen, wenn der User sie im aktuellen Prompt **explizit** für diesen Schritt benennt.

## Modus-Erkennung

Erkenne den Modus automatisch aus Trigger-Phrase und Projektzustand:

| Bedingung | Modus | Details in |
|---|---|---|
| Trigger enthält `pre-check`, `precheck`, `lohnt sich sparring` o.ä. | **Pre-Check** | `references/precheck.md` |
| Trigger enthält Resize-Wörter (`verlängere`, `verkürze`, `extend`, `shorten`, `nach Runde X beenden` etc.) | **RESIZE** | `references/resize.md` |
| Trigger enthält `Turbo`, `Schnellstart`, `ohne Fragen`, `auto`, `quick` | **INIT (Turbo)** | `references/turbo.md` |
| Keine `sparring/*/state.md` vorhanden | **INIT** | unten |
| Genau eine `sparring/*/state.md` mit Status ≠ `completed` | **JOIN** für genau dieses Sparring | unten |
| Mehrere aktive `sparring/*/state.md` | Stoppen, liste aktive Sparrings (Name + Runde + wer dran ist), frage User. Bei explizitem Slug in Trigger: direkt nehmen. | — |
| Nur abgeschlossene Sparrings + JOIN-Phrase | Stoppen, melde dass kein laufendes Sparring existiert | — |
| Nur abgeschlossene Sparrings + INIT-Phrase | INIT für neues Sparring | unten |

Pre-Check hat Vorrang vor allen anderen — er legt nur eine `precheck.md` an und kollidiert nicht mit laufendem State, prüft das aber explizit.

### Notation

Jedes Sparring lebt in einem benannten Unterordner unter `sparring/`, zum Beispiel `sparring/readme-v1/`. `<NAME>` ist der konkrete Slug. **Ersetze `<NAME>` immer durch den konkreten Slug aus dem Interview (INIT) bzw. aus dem erkannten aktiven Sparring (JOIN).**

## Vor jeder Schreibaktion: Vier Gates

Vor jedem Output vier Prüfungen durchlaufen (Role, Input, Output, Execution-Mode). Bei Fehler: nichts schreiben, dem User melden. Details in `references/gates.md` — vor der ersten Schreibaktion einer Sitzung einmal lesen.

## INIT-Modus

**Turbo-Variante:** Wenn die Trigger-Phrase Worte wie "Turbo", "Schnellstart", "ohne Fragen", "auto", "quick" enthält, folge `references/turbo.md` statt dem Interview unten.

### Schritt 1: Interview

**Vor dem Interview:** Sieh dir das aktuelle Projektverzeichnis kurz an (Top-Level-Dateien und -Ordner, ggf. eine `README.md` oder `CLAUDE.md`). Das ist die Grundlage für deine konkreten Vorschläge — du musst sie nicht im Detail lesen, nur Kontext sammeln.

**Format pro Frage:** Stelle die Frage, gib einen **konkreten Vorschlag** und eine **knappe Begründung in 1 Satz**. Dann warte auf Bestätigung oder Korrektur. Eine Frage nach der anderen, nicht alles auf einmal.

Beispiel: *"**Welches Artefakt?** — Ich schlage `README.md` vor. Begründung: das ist die einzige Markdown-Datei im Root und sieht nach dem Hauptartefakt aus. Passt das, oder soll es etwas anderes sein?"*

Die zehn Fragen:

1. **Welches Artefakt soll gechallenged werden?** Schlage konkret eine Datei oder ein Verzeichnis vor, das du im Projekt siehst. Wenn mehrere plausibel sind, nenne 2–3 Kandidaten und empfiehl einen. Wenn nichts Naheliegendes da ist, frag offen nach einem Pfad.
2. **Wie soll dieses Sparring heißen?** Leite einen Slug aus dem Artefakt-Basename ab (z. B. `draft.md` → `draft`). Bei Kollision unter `sparring/` automatisch `-v2`, `-v3` anhängen. Normalisiere: nur Kleinbuchstaben, Ziffern, Bindestriche. Im weiteren Verlauf heißt dieser Slug `<NAME>`.
3. **Welche Projektkontext-Dateien gelten?** Scanne nach Style-Guides, Redaktionsplänen, Briefings, Tone-of-Voice-Dokumenten (Suchmuster DE/EN: `*redaktionsplan*`, `*editorial*`, `*style[-_ ]guide*`, `*styleguide*`, `*briefing*`, `*brand[-_ ]voice*`, `*tone[-_ ]of[-_ ]voice*`, `*content[-_ ]strategy*`, `*personas*`, `*messaging*`, `*positioning*`, plus typspezifisch). Schlage gefundene Dateien als Liste relativer Pfade vor, jeweils mit halbsatziger Begründung. Default leer, wenn nichts gefunden — nicht raten. Diese werden in `artifact.md` unter `Projektkontext` als **referenzierte** Pfade eingetragen (nicht kopiert).
4. **Welches zweite Tool kommt rein?** Default `Codex CLI` oder `andere Claude Code Session` (vollautonom, Wait-Loop funktioniert). `ChatGPT (Web)` nur, wenn der User explizit kein lokales Tool hat. Frag dann nach dem Namen, wie er später in `state.md` stehen soll (z. B. "Codex", "GPT-5").
5. **Mein eigener Name im Sparring?** Default `Claude`.
6. **Sparring-Typ?** Schlage konkret einen der vier Typen vor (`Text`, `Campaign`, `Skill`, `Code`) basierend auf Artefakt: README/Essay → `Text`, Post-Sammlung → `Campaign`, SKILL.md mit Templates → `Skill`, Quellcode → `Code`. Bei Unklarheit `Auto`.
7. **Wie viele Runden?** Schnelltest → `3`, realer Verbesserungsdurchlauf → `5`, tiefe Schärfung → `10`. Begründung soll auf Artefaktgröße und User-Ziel basieren.
8. **Ausführungsmodus?** Default `Subagent`, wenn die Umgebung Subagents erkennbar unterstützt; sonst `Inline`. `Auto` nur bei Unsicherheit. Subagent isoliert Step-Kontexte sauberer und vermeidet Rollenvermischung.
9. **Subagent-Qualität?** Default `Inherit` (keine unnötigen Overrides). `High` oder `Role-based` (These Balanced, Antithese+Synthese High) bei besonders wichtigen Artefakten.
10. **Messung aktivieren?** Default `Off`. Bei `On` siehe der `text-sparring-measurement`-Skill — kostet bei 5 Runden ca. 11 zusätzliche Evaluator-Subagent-Aufrufe. Bei `On` Folgefrage nach `Measurement-Qualität` (Default `High`).

Nach allen 10 Antworten fasse die Konfiguration in 4–6 Zeilen zusammen und hol dir ein finales "Los" vom User, bevor du das Scaffolding anlegst.

### Schritt 2: Scaffolding anlegen

Lege im aktuellen Projektverzeichnis (NICHT im Skill-Verzeichnis) folgende Struktur an:

```
sparring/
└── <NAME>/                       ← der konkrete Slug aus Frage 2
    ├── CHALLENGE.md
    ├── artifact.md
    ├── state.md
    ├── watch_loop.sh
    ├── chatgpt_codex_instructions.md
    ├── context/
    └── rounds/
        └── round_01/
            └── artifact.md|artifact/ ← Kopie des Ausgangsartefakts
```

Vorgehen:

- Prüfe den Artefaktpfad: Datei → `Artifact-Typ: file`, Verzeichnis → `Artifact-Typ: directory`. Weder noch → erneut fragen.
- Bei User-Wahl `Auto`: leite `Erkannter Sparring-Typ` aus Artefakt und Projektkontext ab.
- Lege `sparring/<NAME>/` an. Existiert bereits: stoppe und frage den User.
- Lies `templates/CHALLENGE.md.tpl`, ersetze Platzhalter (Agent-Namen, Gesamtrundenzahl, Rotationsplan, Sparring-Pfad), schreibe nach `sparring/<NAME>/CHALLENGE.md`.
- Lies `templates/artifact.md.tpl`, befülle, schreibe nach `sparring/<NAME>/artifact.md`. `Initiale Kopie` zeigt auf `rounds/round_01/artifact.md` (bei file) bzw. `rounds/round_01/artifact/` (bei directory). Projektkontext-Pfade als Bulletliste eintragen (relativ vom Projekt-Root), bei keinen: `(keine)`.
- Lies `templates/state.md.tpl`, befülle, schreibe nach `sparring/<NAME>/state.md`. Initialer Status: Runde 1, Schritt 1, dran ist der **Initiator** (du), Rolle **These**. Setze alle Felder inkl. `Measurement` und `Measurement-Qualität` (bei `Measurement: off` setze letzteres auf `-`).
- Kopiere `templates/watch_loop.sh` 1:1 nach `sparring/<NAME>/watch_loop.sh`. Nicht ausführbar machen — Aufruf via `bash sparring/<NAME>/watch_loop.sh ...`.
- Lies `templates/chatgpt_codex_instructions.md`, befülle (Projektpfad, Name des zweiten Agents, Sparring-Pfad), schreibe nach `sparring/<NAME>/chatgpt_codex_instructions.md`.
- Lege `sparring/<NAME>/context/` an. `templates/step_context.md.tpl` ist Vorlage für Schritt-Kontexte im Subagent-Modus.
- **Bei `file`**: Kopiere das benannte Artefakt nach `rounds/round_01/artifact.md`.
- **Bei `directory`**: Kopiere nach `rounds/round_01/artifact/`. **Schließe immer aus**: `sparring/`, `.git/`, `node_modules/`, `dist/`, `build/`, `.venv/`, `__pycache__/`, `.DS_Store`. Falls das Artefakt ein Projekt-Root ist und nach Ausschluss noch mehr als drei Top-Level-Einträge bleiben: stoppe und frag nach expliziter Include-Liste. Trage die verwendete Ausschluss-/Include-Liste in `artifact.md` unter `Boundary` ein. Bei Folgerunden gelten die Excludes nicht erneut (dort wird schon das gefilterte Artefakt kopiert).

### Schritt 3: CLAUDE.md erweitern (nur wenn du Claude bist)

Falls eine `CLAUDE.md` im Projektroot existiert: hänge `templates/claude_md_snippet.md` am Ende an. Sonst: neue anlegen mit diesem Inhalt. Ersetze `{MY_NAME}`, `{OTHER_NAME}`, `{SPARRING_PATH}` (= `sparring/<NAME>`).

Wenn schon ein Snippet von einem früheren Sparring drin steht: das neue zusätzlich anhängen, das alte nicht entfernen. Mehrere Snippets nebeneinander sind erlaubt; sie unterscheiden sich durch `{SPARRING_PATH}`.

### Schritt 4: Rotationsplan generieren

Der Plan ist **fest und deterministisch**. Verwende exakt diese Tabelle als 10-Runden-Muster (A = Initiator, B = zweiter Agent):

| Runde | These | Antithese | Synthese |
|-------|-------|-----------|----------|
| 1 | A | B | A |
| 2 | B | A | B |
| 3 | A | B | B |
| 4 | B | A | A |
| 5 | A | A | B |
| 6 | B | B | A |
| 7 | A | B | A |
| 8 | B | A | B |
| 9 | A | B | B |
| 10 | B | A | A |

Bei weniger als 10 Runden gilt nur der Präfix bis zur gewählten Gesamtrundenzahl. Bei genau 10 Runden ist die Verteilung exakt ausbalanciert: jeder Agent macht jede Rolle genau 5×. Schreibe sie in `state.md` mit den echten Namen.

### Schritt 4.5: Baseline-Measurement (nur bei `Measurement: on`)

Bei `Measurement: off` überspringen. Bei `Measurement: on` siehe der `text-sparring-measurement`-Skill, Abschnitt "Baseline" — vor Schritt 5 ausführen.

### Schritt 5: Schritt 1 (These der Runde 1) erledigen

**Bei `Step-Ausführung: subagent`**: Erzeuge `sparring/<NAME>/context/round_01_step_1_prompt.md` aus `templates/step_context.md.tpl` (mit `{SPARRING_PATH}` = `sparring/<NAME>`), beauftrage einen frischen Subagent mit genau diesem Kontext, warte auf Abschluss und prüfe, dass `rounds/round_01/step_1_thesis.md` (bzw. `.../step_1_thesis/`) und `rounds/round_01/step_1_handoff.md` existieren.

**Bei `Step-Ausführung: inline`**: Lies bei `file` `rounds/round_01/artifact.md`; bei `directory` `rounds/round_01/artifact/`. Produziere die These gemäß `CHALLENGE.md`. Schreibe bei `file` nach `rounds/round_01/step_1_thesis.md`, bei `directory` nach `rounds/round_01/step_1_thesis/`, und den Übergabeimpuls immer nach `rounds/round_01/step_1_handoff.md`.

### Schritt 6: state.md aktualisieren

- Schritt-Status: ✅ Schritt 1 erledigt
- `Dran:` auf den zweiten Agent (Name aus Interview)
- Verlauf-Sektion aktualisieren

### Schritt 7: Handover-Prompt ausgeben und Wait-Loop starten

**Vor** dem Wait-Loop musst du dem User einen fertigen, copy-paste-fähigen Handover-Prompt für den zweiten Agenten ausgeben. Format:

> Setup für Sparring **`<NAME>`** steht. Schritt 1 (These) ist fertig. Ich gehe gleich in den Wait-Loop.
>
> **Handover-Prompt für {OTHER_NAME}:**
>
> Starte eine Session in **{OTHER_NAME}** im selben Projektverzeichnis (`{PROJECT_PATH}`) und kopiere genau diesen Text als ersten Prompt:
>
> ````
> Du bist "{OTHER_NAME}" im laufenden Text-Sparring "<NAME>"
> (Sparring-Pfad: sparring/<NAME>/) im aktuellen Projektverzeichnis.
> Steig ins Sparring ein: lies sparring/<NAME>/state.md und
> sparring/<NAME>/CHALLENGE.md, folge dem JOIN-Modus der
> text-sparring-Skill, und übernimm den ausstehenden Schritt.
> Falls die Skill nicht automatisch lädt, lies ihre SKILL.md
> explizit.
> ````

Setze die Platzhalter `{OTHER_NAME}`, `<NAME>` und `{PROJECT_PATH}` mit den konkreten Werten ein, bevor du den Block ausgibst. Der innere Codeblock (mit den vier Backticks außen) muss exakt diese Form behalten, damit der User ihn als einen Block markieren und kopieren kann.

Führe danach aus: `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"`.

Ab Aufruf des Loops gilt Silent Wait Mode (siehe unten).

## JOIN-Modus

### Schritt 1: Aktives Sparring identifizieren und State lesen

Scanne `sparring/*/state.md` nach Status ≠ `completed`. Folge der Modus-Erkennung oben. Merke dir `<NAME>` als den konkret gewählten Slug.

Lies `sparring/<NAME>/state.md` vollständig. Identifiziere: `Sparring-Name`, Initiator, aktuelle Runde + Schritt, deine Rolle, `Artifact-Typ`, `Artifact-Pfad`, `Sparring-Typ`, `Erkannter Sparring-Typ`, `Ausführungsmodus`, `Step-Ausführung`, `Subagent-Qualität`.

- `Dran:` zeigt den bekannten anderen Agenten → starte direkt Wait-Loop mit deinem Namen. Keine Rückfrage.
- `Dran:` zeigt weder dich noch den anderen → stoppe und frage den User (State inkonsistent oder Agent-Name unbekannt).

### Schritt 2: Deinen Schritt erledigen

**Bei `Ausführungsmodus: Subagent`** und du kannst keinen starten: stoppe und frage den User. Kein stiller Fallback.

**Bei `Ausführungsmodus: Auto`**: Subagent wenn dein Tool das erkennbar unterstützt; sonst inline. Aktualisiere `Step-Ausführung` in `state.md`, falls die tatsächliche Umsetzung von der gespeicherten abweicht.

**Bei `Step-Ausführung: subagent`**: Erzeuge vor dem Schritt eine Kontextdatei `sparring/<NAME>/context/round_NN_step_M_prompt.md`, beauftrage einen frischen Subagent mit genau diesem Kontext und prüfe danach, dass die erwarteten Output-Dateien geschrieben wurden. Der Subagent darf `state.md` nicht aktualisieren, keine neue Runde anlegen und keinen Wait-Loop starten.

Übersetze `Subagent-Qualität` in dein Tool: `Inherit` (keine Overrides), `Balanced` (mittlere Qualität), `High` (stärkste verfügbare), `Role-based` (These Balanced, Antithese+Synthese High). Wenn dein Tool keine Subagent-Qualitätswahl erlaubt: faktisch `Inherit`.

**Bei `Step-Ausführung: inline`**: Erledige direkt in der Hauptsession. Alle Pfade unten relativ zu `sparring/<NAME>/`.

- **These**: Bei `file`: Lies `rounds/round_NN/artifact.md`; bei `directory`: lies `rounds/round_NN/artifact/`. Falls `NN > 1`, lies zusätzlich `rounds/round_{NN-1}/step_3_handoff.md`. Schreibe bei `file` nach `rounds/round_NN/step_1_thesis.md`, bei `directory` nach `rounds/round_NN/step_1_thesis/`, und immer nach `rounds/round_NN/step_1_handoff.md`.
- **Antithese**: Bei `file`: Lies `rounds/round_NN/artifact.md`, `rounds/round_NN/step_1_thesis.md` und `rounds/round_NN/step_1_handoff.md`; bei `directory`: Verzeichnis-Varianten. Schreibe immer nach `rounds/round_NN/step_2_antithesis.md` und `rounds/round_NN/step_2_handoff.md`. Auch bei Directory-Artefakten bleibt die Antithese eine Markdown-Datei (strukturierte Kritik, keine neue Artefaktfassung).
- **Synthese**: Lies `rounds/round_NN/step_1_thesis` (Datei oder Verzeichnis), `rounds/round_NN/step_2_antithesis.md` und `rounds/round_NN/step_2_handoff.md`. Schreibe bei `file` nach `rounds/round_NN/step_3_synthesis.md`, bei `directory` nach `rounds/round_NN/step_3_synthesis/`, und immer nach `rounds/round_NN/step_3_handoff.md`.

Befolge dabei zwingend die Rollen-Definitionen aus `sparring/<NAME>/CHALLENGE.md`.

### Schritt 2.5: Measurement nach Synthese (nur bei `Measurement: on` UND erledigter Synthese)

Bei `Measurement: off` ODER der gerade erledigte Step war nicht die Synthese: überspringen. Sonst siehe der `text-sparring-measurement`-Skill, Abschnitt "Nach Synthese" — vor Schritt 3 ausführen.

### Schritt 3: State und ggf. neue Runde aktualisieren

Alle Pfade unten relativ zu `sparring/<NAME>/`.

- Aktualisiere `state.md`: Schritt-Status, `Dran:`, Verlauf.
- **Falls du gerade Synthese (Schritt 3) erledigt hast** UND aktuelle Runde < Gesamtrundenzahl:
  - Lege `rounds/round_{NN+1}/` an
  - Bei `file`: Kopiere `rounds/round_NN/step_3_synthesis.md` → `rounds/round_{NN+1}/artifact.md`
  - Bei `directory`: Kopiere `rounds/round_NN/step_3_synthesis/` → `rounds/round_{NN+1}/artifact/`
  - `step_3_handoff.md` bleibt im abgeschlossenen Rundenordner; die These der nächsten Runde liest ihn dort als Übergabeimpuls.
  - Inkrementiere Runden-Nummer in `state.md`. Setze `Dran:` und Rolle laut Rotationsplan.
- **Falls du gerade Synthese der letzten Runde erledigt hast**:
  - Setze `state.md`-Status auf `completed`
  - Bei `file`: Kopiere `rounds/round_NN/step_3_synthesis.md` → `sparring/<NAME>/FINAL_ARTIFACT.md`
  - Bei `directory`: Kopiere `rounds/round_NN/step_3_synthesis/` → `sparring/<NAME>/FINAL_ARTIFACT/`
  - **Bei `Measurement: on`**: Kopiere zusätzlich `rounds/round_NN/measurement_cumulative.md` → `sparring/<NAME>/MEASUREMENT.md` (siehe der `text-sparring-measurement`-Skill).

### Schritt 4: Wait-Loop starten

Wie im INIT-Modus Schritt 7. Falls dieser Agent zum ersten Mal einsteigt: kein Hinweis an den User mehr nötig, der erste Hinweis kam vom Initiator.

Auch hier gilt Silent Wait Mode: Nach Start von `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"` bleibt der Agent stumm, bis der Prozess mit WAKE, DONE oder TIMEOUT endet.

## Reaktion auf watch_loop

Der Bash-Loop blockiert und beendet sich mit drei möglichen Exit-Codes. Reagiere konkret:

| Exit | Output enthält | Reaktion |
|------|----------------|----------|
| 0 | `WAKE:` und state.md-Inhalt | Du bist wieder dran. Gehe zu JOIN-Modus Schritt 2 (deinen Schritt erledigen). Danach erneut watch_loop aufrufen. |
| 1 | `DONE:` | Alle gewählten Runden durch. Melde dem User: *"Sparring `<NAME>` abgeschlossen — finales Artefakt liegt in `sparring/<NAME>/FINAL_ARTIFACT.md` bzw. `sparring/<NAME>/FINAL_ARTIFACT/`."* Beende sauber, kein neuer Loop. |
| 2 | `TIMEOUT:` | Der andere Agent hat sich 30 Min nicht gemeldet. Frage den User: *"{OTHER_NAME} meldet sich seit 30 Min nicht. Weiter warten, oder Sparring pausieren?"* Bei "weiter": watch_loop erneut starten. |

### Silent Wait Mode

Sobald ein Agent den Wait-Loop startet, bleibt er stumm, bis der Prozess endet.

Erlaubte Reaktionen gibt es nur auf Exit 0 / WAKE, Exit 1 / DONE, Exit 2 / TIMEOUT. Während des Wartens: keine Zwischenberichte, keine Spekulation über den anderen Agenten, keine Plananalyse, keine erneute Zusammenfassung, keine UI-Kommentare wie "weiter wartend" oder "noch kein Wake".

## Spezialmodi

- **Pre-Check** (lohnt sich ein Sparring überhaupt? 3-Dim-Scoring + Vetos) → `references/precheck.md`
- **Turbo** (INIT ohne Interview, AI-defaultet alles) → `references/turbo.md`
- **RESIZE** (laufendes oder abgeschlossenes Sparring verlängern/verkürzen) → `references/resize.md`
- **Measurement** (optional, pro Runde dialektischer Delta-Score gegen Baseline) → der `text-sparring-measurement`-Skill

## Verhaltensregeln (Pflichtlektüre)

Siehe `references/conventions.md` — vor der ersten Aktion einmal lesen. Kurzfassung: Pflichtabschluss nach jedem Schritt (Watch-Loop oder Final-Meldung), nicht den Inhalt bewerten, state.md ist einzige Wahrheit, nie Schritte überspringen, Silent Wait Mode, Hauptoutput und Übergabe trennen, Subagenten nur für Step-Arbeit, keine programmatische Messung/Sektionsextraktion während Step-Arbeit.

## Dateien in diesem Skill

| Datei | Zweck |
|-------|-------|
| `SKILL.md` | Kern-Workflow: Modus-Erkennung, INIT, JOIN, Wait-Loop |
| `references/gates.md` | Vier-Gates-Checkliste vor jeder Schreibaktion |
| `references/turbo.md` | INIT ohne Interview |
| `references/precheck.md` | Sparring-Fit-Bewertung vor Setup |
| `references/resize.md` | Runden nachträglich ändern |
| `references/conventions.md` | Verhaltensregeln und Verbote |
| `templates/CHALLENGE.md.tpl` | Regelwerk + Rollen-Definitionen + Rotationsplan-Schema |
| `templates/state.md.tpl` | Status-Datei mit Platzhaltern |
| `templates/artifact.md.tpl` | Stabile Definition des gechallengten Artefakts |
| `templates/claude_md_snippet.md` | Anhang für CLAUDE.md im Projekt |
| `templates/chatgpt_codex_instructions.md` | Instructions für den zweiten Agent |
| `templates/step_context.md.tpl` | Vorlage für isolierte Subagent-Step-Kontexte |
| `templates/watch_loop.sh` | Bash-Polling-Script, pure POSIX |
| `templates/precheck_rubric.md` | 3-Dim-Rubric für Pre-Check, inkl. Vetos und Größen-Cap |
| `templates/precheck_context.md.tpl` | Vorlage für inline Pre-Check der Hauptsession |

Für die optionale Qualitätsmessung siehe den Sibling-Skill **`text-sparring-measurement`**.
