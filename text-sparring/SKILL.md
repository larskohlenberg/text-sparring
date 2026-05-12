---
name: text-sparring
description: Set up an autonomous multi-agent text sparring loop where two AI agents iteratively refine a text artifact over configurable rounds using Thesis → Antithesis → Synthesis. Multiple sparrings per project are supported via named subfolders under `sparring/`. Use this skill whenever the user wants two agents to "spar" over a text, mutually challenge or refine a draft, or run a dialectical improvement loop. Trigger on requests like "starte ein Text-Sparring", "lass zwei Agenten meinen Text gegenseitig schärfen", "richte einen dialektischen Loop ein", "set up a text sparring", "let two agents spar on this draft", or any mention of "Text-Sparring", "Agent-Sparring", "Multi-Agent-Refinement". Also trigger when an agent is asked to JOIN an existing sparring ("steig ins Sparring ein", "steig ins Sparring <name> ein", "join the running sparring", "übernimm Schritt 2"). The skill is harness-agnostic and requires no external tools beyond bash and standard Unix utilities.
---

# Text Sparring

Ein harness-agnostischer Skill zum Aufsetzen und Mitwirken an einem **Text-Sparring zwischen zwei AI-Agenten**. Zwei Agenten durchlaufen eine konfigurierbare Anzahl von Runden mit den Rollen **These → Antithese → Synthese**.

Es geht **nicht ums Gewinnen**, sondern um gegenseitiges Schärfen — wie zwei Sparringspartner im Training. Der Skill kennt keinen Inhalt; er orchestriert nur den **Prozess**. Der zu sparrende Text liegt außerhalb des Skills im Projektverzeichnis.

## Wann triggern

Triggere diesen Skill in zwei Situationen:

1. **INIT** — Der User möchte ein neues Sparring starten ("Lass meinen Text sparren", "Setup Text-Sparring für draft.md").
2. **JOIN** — Der User sagt einem zweiten Agent, dass er in ein laufendes Sparring einsteigen soll ("Steig ins Sparring ein", "Codex, übernimm").

### Notation in diesem Skill

Jedes Sparring lebt in einem benannten Unterordner unter `sparring/`, zum Beispiel `sparring/readme-v1/`. In diesem Skill steht `<NAME>` als Platzhalter für diesen Slug. **Ersetze `<NAME>` immer durch den konkreten Slug aus dem Interview (INIT-Modus) bzw. aus dem erkannten aktiven Sparring (JOIN-Modus).** Das übergeordnete `sparring/` ist der Container für alle Sparrings in diesem Projekt.

### Modus-Erkennung

Erkenne den Modus automatisch:

- **Keine `sparring/*/state.md`-Dateien vorhanden** → INIT.
- **Genau eine `sparring/*/state.md` mit Status ≠ `completed`** → JOIN für genau dieses Sparring.
- **Mehrere `sparring/*/state.md` mit Status ≠ `completed`** → Stoppe, liste die aktiven Sparrings (Name + aktuelle Runde + wer dran ist) und frage den User, welches gemeint ist. Falls der User in der Trigger-Phrase einen Namen genannt hat (z. B. *"Steig ins Sparring readme-v2 ein"*), nimm diesen direkt ohne Rückfrage.
- **Nur abgeschlossene Sparrings (alle `completed`)** und User triggert mit JOIN-Phrase → Stoppe und melde, dass kein laufendes Sparring existiert.
- **Nur abgeschlossene Sparrings** und User triggert mit INIT-Phrase → INIT für ein neues Sparring.

## Drei harte Gates vor jeder Schreibaktion

Vor jedem Output diese vier Prüfungen durchlaufen. Wenn ein Gate fehlschlägt: **nichts schreiben**, dem User melden, welche Datei oder welches Feld konkret nicht passt. Nicht raten, nicht reparieren.

1. **Role Gate** — Wirst du mit einer expliziten Kontextdatei `sparring/<NAME>/context/round_NN_step_M_prompt.md` aufgerufen, bist du **Step Worker**: erledige genau diesen einen Schritt, schreibe nur die im Kontext genannten Output-Pfade. Du liest oder änderst **nicht** `state.md`, legst keine neuen Runden an, kopierst keine Final-Artefakte, startest keinen Wait-Loop. Ohne Kontextdatei bist du **Hauptsession** und folgst INIT- oder JOIN-Modus.
2. **Input Gate** — Alle für deine Rolle erwarteten Inputs existieren und sind lesbar (`artifact.md`, die Runden-Dateien aus den Vorgängerschritten, ggf. Vorrunden-Handoff). Bei Directory-Inputs muss das Verzeichnis tatsächlich Dateien enthalten.
3. **Output Gate** — Die für deine Rolle erwarteten Output-Pfade enthalten noch keinen Inhalt. Findest du dort schon Text oder Dateien, ist der Schritt vermutlich bereits gelaufen — melde das dem User, statt zu überschreiben.
4. **Execution Mode Gate** — Steht in `state.md` `Ausführungsmodus: Subagent`, kannst du aber keinen Subagenten starten: **sofort stoppen und den User fragen**. Kein stiller Fallback auf Inline. Kein Weitermachen mit dem nächsten Schritt.

## INIT-Modus (erste Aktivierung)

### Schritt 1: Interview

Stelle dem User exakt diese Fragen — eine nach der anderen, kompakt:

1. **Welches Artefakt soll gechallenged werden?** Erwarte einen Pfad zu einer Datei oder einem Verzeichnis (z. B. `draft.md`, `docs/`, `text-sparring/`).
2. **Wie soll dieses Sparring heißen?** Default: aus dem Artefakt-Basename abgeleitet (z. B. `draft.md` → `draft`, `text-sparring/` → `text-sparring`). Falls unter `sparring/` schon ein Ordner mit diesem Namen existiert, hänge automatisch einen aufsteigenden Suffix `-v2`, `-v3` an und biete den so entstandenen Namen als Default an. Normalisiere die User-Eingabe vor dem Anlegen: nur Kleinbuchstaben, Ziffern und Bindestriche; ersetze Leerzeichen und Unterstriche durch `-`; entferne sonstige Sonderzeichen. Zeige dem User den finalen Slug zur Bestätigung, bevor du das Verzeichnis anlegst. Im weiteren Verlauf des Skills wird dieser Slug `<NAME>` genannt.
3. **Welches zweite Tool kommt rein?** Optionen: `Codex CLI`, `ChatGPT (Web)`, `Cowork`, `andere Claude Code Session`. Frag nach dem Namen, wie er später in `state.md` referenziert werden soll (z. B. "Codex", "GPT-5").
4. **Mein eigener Name im Sparring?** Default: `Claude`. Akzeptiere Abweichungen.
5. **Sparring-Typ?** Default: `Auto`. Optionen:
   - `Auto`: aus Artefakt und Projektkontext ableiten.
   - `Text`: generische Text-, README-, Essay- oder Konzeptarbeit.
   - `Campaign`: Posts, Kampagnen, Content-Serien oder Redaktionsmaterial.
   - `Skill`: Skills, Agent-Workflows, Prompt-/Template-Systeme oder `.skill`-Bundles.
   - `Code`: Quellcode, Tests, Build-Dateien oder technische Implementierungen.
6. **Wie viele Runden?** Default: `10`. Akzeptiere ganze Zahlen von 1 bis 10. Für schnelle Tests sind 2–3 Runden sinnvoll; für gründliche Schärfung 5–10.
7. **Ausführungsmodus?** Default: `Auto`. Optionen:
   - `Auto`: Subagent/Worker/Workstream verwenden, wenn das aktuelle Tool das erkennbar unterstützt; sonst inline.
   - `Subagent`: jeden Schritt in einem frischen Subagent-Kontext ausführen. Wenn das aktuelle Tool das nicht kann, stoppen und den User fragen.
   - `Inline`: Schritte direkt in der Hauptsession ausführen.
8. **Subagent-Qualität?** Default: `Inherit`. Optionen:
   - `Inherit`: Subagents übernehmen Modell/Qualität der Hauptsession; keine expliziten Overrides setzen.
   - `Balanced`: mittlere Qualität/Kosten, wenn das Tool eine Qualitätswahl erlaubt.
   - `High`: stärkste sinnvoll verfügbare Qualität, wenn das Tool eine Qualitätswahl erlaubt.
   - `Role-based`: These eher Balanced, Antithese und Synthese eher High.

### Schritt 2: Scaffolding anlegen

Lege im aktuellen Projektverzeichnis (NICHT im Skill-Verzeichnis) folgende Struktur an. Der äußere `sparring/`-Container existiert für alle Sparrings im Projekt; jedes einzelne Sparring lebt in einem benannten Unterordner:

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

- Prüfe den Artefaktpfad: Wenn er eine Datei ist, setze `Artifact-Typ` auf `file`; wenn er ein Verzeichnis ist, setze `Artifact-Typ` auf `directory`. Wenn er weder Datei noch Verzeichnis ist, frage den User erneut.
- Bestimme `Erkannter Sparring-Typ`: Bei User-Wahl `Auto` leite aus Artefakt und Projektkontext `Text`, `Campaign`, `Skill` oder `Code` ab. Bei expliziter User-Wahl übernimm diese als erkannten Typ, außer Artefakt und Typ widersprechen offensichtlich.
- Lege das Verzeichnis `sparring/<NAME>/` an. Falls es bereits existiert (Race oder unerkannter Konflikt): stoppe und frage den User.
- Lies `templates/CHALLENGE.md.tpl` und ersetze die Platzhalter mit den konkreten Agent-Namen, der gewählten Gesamtrundenzahl, dem unten beschriebenen Rotationsplan und dem Sparring-Pfad `sparring/<NAME>`. Schreibe das Ergebnis nach `sparring/<NAME>/CHALLENGE.md`.
- Lies `templates/artifact.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/<NAME>/artifact.md`. Setze `Initiale Kopie` auf `sparring/<NAME>/rounds/round_01/artifact.md` bei Dateien oder `sparring/<NAME>/rounds/round_01/artifact/` bei Verzeichnissen.
- Lies `templates/state.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/<NAME>/state.md`. Setze `Sparring-Name` auf `<NAME>`. Setze den initialen Status auf: Runde 1 von gewählter Gesamtrundenzahl, Schritt 1, dran ist der **Initiator** (also du selbst), Rolle ist **These**. Setze `Artifact-Typ`, `Artifact-Pfad`, `Sparring-Typ`, `Erkannter Sparring-Typ`, `Ausführungsmodus`, `Step-Ausführung` und `Subagent-Qualität`.
- Kopiere `templates/watch_loop.sh` 1:1 nach `sparring/<NAME>/watch_loop.sh`. Mache sie nicht ausführbar — sie wird mit `bash sparring/<NAME>/watch_loop.sh ...` aufgerufen. Das Skript lokalisiert seine `state.md` über sein eigenes Verzeichnis, kein extra Argument nötig.
- Lies `templates/chatgpt_codex_instructions.md`, befülle die Platzhalter mit dem Projektpfad, dem Namen des zweiten Agents und dem Sparring-Pfad `sparring/<NAME>`, schreibe nach `sparring/<NAME>/chatgpt_codex_instructions.md`.
- Lege `sparring/<NAME>/context/` an. Nutze `templates/step_context.md.tpl` später als Vorlage für Schritt-Kontexte im Subagent-Modus.
- Bei `Artifact-Typ: file`: Kopiere die vom User benannte Datei nach `sparring/<NAME>/rounds/round_01/artifact.md`.
- Bei `Artifact-Typ: directory`: Kopiere das vom User benannte Verzeichnis nach `sparring/<NAME>/rounds/round_01/artifact/`. **Schließe dabei immer aus**: `sparring/`, `.git/`, `node_modules/`, `dist/`, `build/`, `.venv/`, `__pycache__/`, `.DS_Store`. Falls das Artefakt ein Projekt-Root ist (Top-Level mit `.git/`, `package.json`, `pyproject.toml` o.ä.) und nach Ausschluss noch mehr als drei Top-Level-Einträge bleiben: stoppe und frage den User nach einer expliziten Include-Liste, bevor du kopierst. Trage die tatsächlich verwendete Ausschluss- bzw. Include-Liste in `sparring/<NAME>/artifact.md` unter `Boundary` ein. Bei Folgerunden (Synthese → nächste Runde) gelten die Excludes nicht erneut, weil dort schon das gefilterte Artefakt kopiert wird.

### Schritt 3: CLAUDE.md erweitern (nur wenn du Claude bist)

Falls eine `CLAUDE.md` im Projektroot existiert: hänge den Inhalt von `templates/claude_md_snippet.md` am Ende an. Falls keine existiert: lege eine neue mit diesem Inhalt an.

Ersetze im Snippet die Platzhalter `{MY_NAME}`, `{OTHER_NAME}` und `{SPARRING_PATH}` mit den konkreten Werten aus dem Interview. `{SPARRING_PATH}` ist `sparring/<NAME>`.

**Beachte:** Wenn in dieser CLAUDE.md bereits ein Snippet von einem früheren Sparring im selben Projekt steht, hänge das neue Snippet zusätzlich an — entferne das alte nicht. Mehrere Sparring-Snippets nebeneinander sind ausdrücklich erlaubt; sie unterscheiden sich durch `{SPARRING_PATH}`.

### Schritt 4: Rotationsplan generieren

Der Plan ist **fest und deterministisch** — er gilt für jedes Setup gleich, nur die Namen werden eingesetzt. Verwende exakt diese Tabelle als 10-Runden-Muster (A = Initiator, B = zweiter Agent):

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

Bei weniger als 10 Runden gilt nur der Präfix bis zur gewählten Gesamtrundenzahl. Bei genau 10 Runden ist die Verteilung exakt ausbalanciert: jeder Agent macht jede Rolle genau 5×.

Schreibe sie in `state.md` mit den echten Namen statt A/B.

### Schritt 5: Schritt 1 (These der Runde 1) erledigen

Wenn `Step-Ausführung: subagent` gilt: Erzeuge zuerst `sparring/<NAME>/context/round_01_step_1_prompt.md` aus `templates/step_context.md.tpl` (mit `{SPARRING_PATH}` = `sparring/<NAME>`), beauftrage einen frischen Subagent/Worker/Workstream mit genau diesem Kontext, warte auf Abschluss und prüfe, dass `sparring/<NAME>/rounds/round_01/step_1_thesis.md` (bzw. `.../step_1_thesis/`) und `sparring/<NAME>/rounds/round_01/step_1_handoff.md` existieren.

Wenn `Step-Ausführung: inline` gilt: Lies bei `Artifact-Typ: file` `sparring/<NAME>/rounds/round_01/artifact.md`; lies bei `Artifact-Typ: directory` `sparring/<NAME>/rounds/round_01/artifact/`. Produziere die These gemäß den Regeln in `sparring/<NAME>/CHALLENGE.md`. Schreibe bei `file` nach `sparring/<NAME>/rounds/round_01/step_1_thesis.md`, bei `directory` nach `sparring/<NAME>/rounds/round_01/step_1_thesis/`, und den Übergabeimpuls immer nach `sparring/<NAME>/rounds/round_01/step_1_handoff.md`.

### Schritt 6: state.md aktualisieren

Setze in `sparring/<NAME>/state.md`:
- Aktueller Schritt-Status: ✅ Schritt 1 erledigt
- `Dran:` auf den zweiten Agent (Name aus Interview)
- Aktualisiere die Verlauf-Sektion

### Schritt 7: Wait-Loop starten

Führe aus: `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"` mit deinem konkreten Namen und dem konkreten Sparring-Pfad.

Erkläre dem User **vor** dem Aufruf in einem kurzen Satz:

> *"Setup für Sparring **`<NAME>`** steht. Schritt 1 (These) ist fertig. Ich gehe jetzt in den Wait-Loop und prüfe alle 30 Sekunden, ob ich wieder dran bin. Bitte starte jetzt eine Session in **{OTHER_NAME}** im selben Projektverzeichnis und sag dort: 'Steig ins Sparring `<NAME>` ein'."*

Dann den Loop aufrufen. Ab diesem Moment gilt Silent Wait Mode: Keine Zwischenkommentare, keine Statusmeldungen, keine Spekulation über den anderen Agenten. Erst wieder reagieren, wenn `watch_loop.sh` mit WAKE, DONE oder TIMEOUT endet.

## JOIN-Modus (zweiter Agent steigt ein)

### Schritt 1: Aktives Sparring identifizieren und State lesen

Scanne zuerst `sparring/*/state.md` nach Sparrings mit Status ≠ `completed`. Folge der Modus-Erkennung oben: bei genau einem aktiven Sparring nimm dieses; bei mehreren aktiven (und ohne Namen in der Trigger-Phrase) frage den User; bei keinem aktiven melde den Zustand. Merke dir `<NAME>` als den konkret gewählten Slug.

Lies `sparring/<NAME>/state.md` vollständig. Identifiziere:
- `Sparring-Name` (zur Bestätigung gegen den erkannten Slug)
- Wer der Initiator ist
- Welche Runde und welcher Schritt aktuell offen ist
- Welche Rolle du in diesem Schritt hast
- Welcher `Artifact-Typ`, `Artifact-Pfad`, `Sparring-Typ` und `Erkannter Sparring-Typ` gelten
- Welcher `Ausführungsmodus`, welche `Step-Ausführung` und welche `Subagent-Qualität` gelten

Falls `Dran:` den bekannten anderen Agenten zeigt: Starte direkt den Wait-Loop mit deinem Namen. Keine Rückfrage.

Falls `Dran:` weder dich noch den bekannten anderen Agenten zeigt: Stoppe und frage den User, weil der State inkonsistent oder ein Agent-Name unbekannt ist.

### Schritt 2: Deinen Schritt erledigen

Wenn `Ausführungsmodus: Subagent` gesetzt ist und du keinen Subagent/Worker/Workstream starten kannst: Stoppe und frage den User. Kein stiller Fallback auf inline.

Wenn `Ausführungsmodus: Auto` gesetzt ist: Verwende Subagent-Ausführung, wenn dein aktuelles Tool das erkennbar unterstützt; sonst verwende inline. Aktualisiere `Step-Ausführung` in `state.md`, falls deine tatsächliche Umsetzung von der gespeicherten abweicht.

Wenn `Step-Ausführung: subagent` gilt: Erzeuge vor dem Schritt eine Kontextdatei in `sparring/<NAME>/context/round_NN_step_M_prompt.md`, beauftrage einen frischen Subagent/Worker/Workstream mit genau diesem Kontext und prüfe danach, dass die erwarteten Output-Dateien geschrieben wurden. Der Subagent darf `state.md` nicht aktualisieren, keine neue Runde anlegen und keinen Wait-Loop starten. Übersetze `Subagent-Qualität` in die beste verfügbare Modell-/Reasoning-Einstellung deines Tools:

- `Inherit`: keine Modell- oder Reasoning-Overrides setzen.
- `Balanced`: mittlere Qualität/Kosten wählen, falls möglich.
- `High`: stärkste sinnvoll verfügbare Qualität wählen, falls möglich.
- `Role-based`: These mit Balanced, Antithese und Synthese mit High ausführen, falls möglich.

Wenn dein Tool keine Subagent-Qualitätswahl erlaubt, ist das kein Fehler; verwende faktisch `Inherit`.

Wenn `Step-Ausführung: inline` gilt: Erledige den Schritt direkt in der Hauptsession. Alle Pfade unten sind relativ zu `sparring/<NAME>/`.

- **These**: Bei `file`: Lies `rounds/round_NN/artifact.md`; bei `directory`: lies `rounds/round_NN/artifact/`. Falls `NN > 1`, lies zusätzlich den Übergabeimpuls der Vorrunde (`rounds/round_{NN-1}/step_3_handoff.md`). Schreibe bei `file` nach `rounds/round_NN/step_1_thesis.md`, bei `directory` nach `rounds/round_NN/step_1_thesis/`, und immer nach `rounds/round_NN/step_1_handoff.md`.
- **Antithese**: Bei `file`: Lies `rounds/round_NN/artifact.md`, `rounds/round_NN/step_1_thesis.md` und `rounds/round_NN/step_1_handoff.md`; bei `directory`: lies `rounds/round_NN/artifact/`, `rounds/round_NN/step_1_thesis/` und `rounds/round_NN/step_1_handoff.md`. Schreibe immer nach `rounds/round_NN/step_2_antithesis.md` und `rounds/round_NN/step_2_handoff.md`. Auch bei Directory-Artefakten bleibt die Antithese eine Markdown-Datei, weil sie keine neue Artefaktfassung erzeugt, sondern strukturierte Kritik.
- **Synthese**: Lies `rounds/round_NN/step_1_thesis` (Datei oder Verzeichnis), `rounds/round_NN/step_2_antithesis.md` und `rounds/round_NN/step_2_handoff.md`. Schreibe bei `file` nach `rounds/round_NN/step_3_synthesis.md`, bei `directory` nach `rounds/round_NN/step_3_synthesis/`, und immer nach `rounds/round_NN/step_3_handoff.md`.

Befolge dabei zwingend die Rollen-Definitionen aus `sparring/<NAME>/CHALLENGE.md`.

### Schritt 3: State und ggf. neue Runde aktualisieren

Alle Pfade unten relativ zu `sparring/<NAME>/`.

- Aktualisiere `state.md`: Schritt-Status, `Dran:`, Verlauf.
- **Falls du gerade Schritt 3 (Synthese) erledigt hast** UND die aktuelle Runde < Gesamtrundenzahl ist:
  - Lege `rounds/round_{NN+1}/` an
  - Bei `Artifact-Typ: file`: Kopiere `rounds/round_NN/step_3_synthesis.md` nach `rounds/round_{NN+1}/artifact.md`
  - Bei `Artifact-Typ: directory`: Kopiere `rounds/round_NN/step_3_synthesis/` nach `rounds/round_{NN+1}/artifact/`
  - Belasse `step_3_handoff.md` im abgeschlossenen Rundenordner; die These der nächsten Runde liest ihn dort als Übergabeimpuls.
  - Inkrementiere die Runden-Nummer in `state.md`
  - Setze `Dran:` und Rolle laut Rotationsplan für die neue Runde
- **Falls du gerade Schritt 3 der letzten Runde erledigt hast**:
  - Setze in `state.md` den Status auf `completed`
  - Bei `Artifact-Typ: file`: Kopiere `rounds/round_NN/step_3_synthesis.md` nach `sparring/<NAME>/FINAL_ARTIFACT.md`
  - Bei `Artifact-Typ: directory`: Kopiere `rounds/round_NN/step_3_synthesis/` nach `sparring/<NAME>/FINAL_ARTIFACT/`

### Schritt 4: Wait-Loop starten

Wie im INIT-Modus Schritt 7. Falls dieser Agent zum ersten Mal ins Sparring einsteigt: kein Hinweis an den User mehr nötig, der erste Hinweis kam vom Initiator.

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

Erlaubte Reaktionen gibt es nur auf:
- Exit 0 / WAKE
- Exit 1 / DONE
- Exit 2 / TIMEOUT

Während des Wartens:
- Keine Zwischenberichte.
- Keine Spekulation über den anderen Agenten.
- Keine Plananalyse.
- Keine erneute Zusammenfassung.
- Keine UI-Kommentare wie "weiter wartend" oder "noch kein Wake".

## Wichtige Verhaltensregeln

- **Pflichtabschluss nach jedem Schritt** — nach dem State.md-Update gibt es genau zwei gültige Zustände: Watch Loop starten (Sparring läuft noch) oder dem User das finale Artefakt melden (letzte Runde abgeschlossen). Jeder andere Abschluss — insbesondere Still-Fertig-Sein ohne Watch Loop — ist ein Fehler.
- **Nicht den Inhalt bewerten** — der Skill befolgt nur den Prozess. Die Rollen in CHALLENGE.md geben vor, wie zu denken ist (radikal hinterfragen, integrieren ohne Kompromiss usw.). Verlass dich darauf.
- **state.md ist die einzige Wahrheit** — vor jeder Aktion erneut lesen. Kein Caching im Kopf.
- **Niemals Schritte überspringen** oder mehrere Schritte in einer Aktivierung erledigen. Pro Aufwachen genau ein Schritt, dann zurück in den Loop.
- **Silent Wait Mode** — während `watch_loop.sh` läuft, keine Zwischenkommentare oder Statusmeldungen ausgeben.
- **Hauptoutput und Übergabe trennen** — These/Synthese bleiben reine Textfassungen; Prüfimpulse gehören ausschließlich in `*_handoff.md`.
- **Subagenten nur für Step-Arbeit** — Subagents schreiben ausschließlich die erwarteten Output-Dateien. Nur die Hauptsession aktualisiert `state.md`, legt neue Runden an und startet den Wait-Loop.
- **Bei Konflikten**: Wenn state.md inkonsistent wirkt (z. B. Verlauf sagt Schritt 2 fertig, aber Datei fehlt), melde es dem User statt zu raten.

## Dateien in diesem Skill

| Datei | Zweck |
|-------|-------|
| `templates/CHALLENGE.md.tpl` | Regelwerk + Rollen-Definitionen + Rotationsplan-Schema |
| `templates/state.md.tpl` | Status-Datei mit Platzhaltern |
| `templates/artifact.md.tpl` | Stabile Definition des gechallengten Artefakts |
| `templates/claude_md_snippet.md` | Anhang für CLAUDE.md im Projekt |
| `templates/chatgpt_codex_instructions.md` | Instructions für den zweiten Agent (Custom Instructions o. Ä.) |
| `templates/step_context.md.tpl` | Vorlage für isolierte Subagent-Step-Kontexte |
| `templates/watch_loop.sh` | Bash-Polling-Script, pure POSIX |
| `templates/round_artifact.md.tpl` | (Reserve, derzeit ungenutzt — Ausgangstext wird direkt kopiert) |

Platzhalter in den Templates haben die Form `{NAME}` und werden beim Scaffolding ersetzt.
