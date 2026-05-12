---
name: text-sparring
description: Set up an autonomous multi-agent text sparring loop where two AI agents iteratively refine a text artifact over configurable rounds using Thesis → Antithesis → Synthesis. Use this skill whenever the user wants two agents to "spar" over a text, mutually challenge or refine a draft, or run a dialectical improvement loop. Trigger on requests like "starte ein Text-Sparring", "lass zwei Agenten meinen Text gegenseitig schärfen", "richte einen dialektischen Loop ein", "set up a text sparring", "let two agents spar on this draft", or any mention of "Text-Sparring", "Agent-Sparring", "Multi-Agent-Refinement". Also trigger when an agent is asked to JOIN an existing sparring ("steig ins Sparring ein", "join the running sparring", "übernimm Schritt 2"). The skill is harness-agnostic and requires no external tools beyond bash and standard Unix utilities.
---

# Text Sparring

Ein harness-agnostischer Skill zum Aufsetzen und Mitwirken an einem **Text-Sparring zwischen zwei AI-Agenten**. Zwei Agenten durchlaufen eine konfigurierbare Anzahl von Runden mit den Rollen **These → Antithese → Synthese**.

Es geht **nicht ums Gewinnen**, sondern um gegenseitiges Schärfen — wie zwei Sparringspartner im Training. Der Skill kennt keinen Inhalt; er orchestriert nur den **Prozess**. Der zu sparrende Text liegt außerhalb des Skills im Projektverzeichnis.

## Wann triggern

Triggere diesen Skill in zwei Situationen:

1. **INIT** — Der User möchte ein neues Sparring starten ("Lass meinen Text sparren", "Setup Text-Sparring für draft.md").
2. **JOIN** — Der User sagt einem zweiten Agent, dass er in ein laufendes Sparring einsteigen soll ("Steig ins Sparring ein", "Codex, übernimm").

Erkenne den Modus automatisch: Existiert `sparring/state.md` im aktuellen Projektverzeichnis → JOIN. Ansonsten → INIT.

## INIT-Modus (erste Aktivierung)

### Schritt 1: Interview

Stelle dem User exakt diese Fragen — eine nach der anderen, kompakt:

1. **Welches Artefakt soll gechallenged werden?** Erwarte einen Pfad zu einer Datei oder einem Verzeichnis (z. B. `draft.md`, `docs/`, `text-sparring/`).
2. **Welches zweite Tool kommt rein?** Optionen: `Codex CLI`, `ChatGPT (Web)`, `Cowork`, `andere Claude Code Session`. Frag nach dem Namen, wie er später in `state.md` referenziert werden soll (z. B. "Codex", "GPT-5").
3. **Mein eigener Name im Sparring?** Default: `Claude`. Akzeptiere Abweichungen.
4. **Sparring-Typ?** Default: `Auto`. Optionen:
   - `Auto`: aus Artefakt und Projektkontext ableiten.
   - `Text`: generische Text-, README-, Essay- oder Konzeptarbeit.
   - `Campaign`: Posts, Kampagnen, Content-Serien oder Redaktionsmaterial.
   - `Skill`: Skills, Agent-Workflows, Prompt-/Template-Systeme oder `.skill`-Bundles.
   - `Code`: Quellcode, Tests, Build-Dateien oder technische Implementierungen.
5. **Wie viele Runden?** Default: `10`. Akzeptiere ganze Zahlen von 1 bis 10. Für schnelle Tests sind 2–3 Runden sinnvoll; für gründliche Schärfung 5–10.
6. **Ausführungsmodus?** Default: `Auto`. Optionen:
   - `Auto`: Subagent/Worker/Workstream verwenden, wenn das aktuelle Tool das erkennbar unterstützt; sonst inline.
   - `Subagent`: jeden Schritt in einem frischen Subagent-Kontext ausführen. Wenn das aktuelle Tool das nicht kann, stoppen und den User fragen.
   - `Inline`: Schritte direkt in der Hauptsession ausführen.
7. **Subagent-Qualität?** Default: `Inherit`. Optionen:
   - `Inherit`: Subagents übernehmen Modell/Qualität der Hauptsession; keine expliziten Overrides setzen.
   - `Balanced`: mittlere Qualität/Kosten, wenn das Tool eine Qualitätswahl erlaubt.
   - `High`: stärkste sinnvoll verfügbare Qualität, wenn das Tool eine Qualitätswahl erlaubt.
   - `Role-based`: These eher Balanced, Antithese und Synthese eher High.

### Schritt 2: Scaffolding anlegen

Lege im aktuellen Projektverzeichnis (NICHT im Skill-Verzeichnis) folgende Struktur an:

```
sparring/
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
- Lies `templates/CHALLENGE.md.tpl` und ersetze die Platzhalter mit den konkreten Agent-Namen, der gewählten Gesamtrundenzahl und dem unten beschriebenen Rotationsplan. Schreibe das Ergebnis nach `sparring/CHALLENGE.md`.
- Lies `templates/artifact.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/artifact.md`. Setze `Initiale Kopie` auf `sparring/rounds/round_01/artifact.md` bei Dateien oder `sparring/rounds/round_01/artifact/` bei Verzeichnissen.
- Lies `templates/state.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/state.md`. Setze den initialen Status auf: Runde 1 von gewählter Gesamtrundenzahl, Schritt 1, dran ist der **Initiator** (also du selbst), Rolle ist **These**. Setze `Artifact-Typ`, `Artifact-Pfad`, `Sparring-Typ`, `Erkannter Sparring-Typ`, `Ausführungsmodus`, `Step-Ausführung` und `Subagent-Qualität`.
- Kopiere `templates/watch_loop.sh` 1:1 nach `sparring/watch_loop.sh`. Mache sie nicht ausführbar — sie wird mit `bash watch_loop.sh ...` aufgerufen.
- Lies `templates/chatgpt_codex_instructions.md`, befülle die Platzhalter mit dem Projektpfad und dem Namen des zweiten Agents, schreibe nach `sparring/chatgpt_codex_instructions.md`.
- Lege `sparring/context/` an. Nutze `templates/step_context.md.tpl` später als Vorlage für Schritt-Kontexte im Subagent-Modus.
- Bei `Artifact-Typ: file`: Kopiere die vom User benannte Datei nach `sparring/rounds/round_01/artifact.md`.
- Bei `Artifact-Typ: directory`: Kopiere das vom User benannte Verzeichnis nach `sparring/rounds/round_01/artifact/`.

### Schritt 3: CLAUDE.md erweitern (nur wenn du Claude bist)

Falls eine `CLAUDE.md` im Projektroot existiert: hänge den Inhalt von `templates/claude_md_snippet.md` am Ende an. Falls keine existiert: lege eine neue mit diesem Inhalt an.

Ersetze im Snippet die Platzhalter `{MY_NAME}` und `{OTHER_NAME}` mit den konkreten Werten aus dem Interview.

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

Wenn `Step-Ausführung: subagent` gilt: Erzeuge zuerst `sparring/context/round_01_step_1_prompt.md` aus `templates/step_context.md.tpl`, beauftrage einen frischen Subagent/Worker/Workstream mit genau diesem Kontext, warte auf Abschluss und prüfe, dass `step_1_thesis.md` und `step_1_handoff.md` existieren.

Wenn `Step-Ausführung: inline` gilt: Lies bei `Artifact-Typ: file` `sparring/rounds/round_01/artifact.md`; lies bei `Artifact-Typ: directory` `sparring/rounds/round_01/artifact/`. Produziere die These gemäß den Regeln in `CHALLENGE.md`. Schreibe bei `file` nach `step_1_thesis.md`, bei `directory` nach `step_1_thesis/`, und den Übergabeimpuls immer nach `step_1_handoff.md`.

### Schritt 6: state.md aktualisieren

Setze in `state.md`:
- Aktueller Schritt-Status: ✅ Schritt 1 erledigt
- `Dran:` auf den zweiten Agent (Name aus Interview)
- Aktualisiere die Verlauf-Sektion

### Schritt 7: Wait-Loop starten

Führe aus: `bash sparring/watch_loop.sh "{MY_NAME}"` mit deinem konkreten Namen.

Erkläre dem User **vor** dem Aufruf in einem kurzen Satz:

> *"Setup steht. Schritt 1 (These) ist fertig. Ich gehe jetzt in den Wait-Loop und prüfe alle 30 Sekunden, ob ich wieder dran bin. Bitte starte jetzt eine Session in **{OTHER_NAME}** im selben Projektverzeichnis und sag dort: 'Steig ins Sparring ein'."*

Dann den Loop aufrufen. Reagiere auf den Exit-Code (siehe unten "Reaktion auf watch_loop").

## JOIN-Modus (zweiter Agent steigt ein)

### Schritt 1: State lesen

Lies `sparring/state.md` vollständig. Identifiziere:
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

Wenn `Step-Ausführung: subagent` gilt: Erzeuge vor dem Schritt eine Kontextdatei in `sparring/context/round_NN_step_M_prompt.md`, beauftrage einen frischen Subagent/Worker/Workstream mit genau diesem Kontext und prüfe danach, dass die erwarteten Output-Dateien geschrieben wurden. Der Subagent darf `state.md` nicht aktualisieren, keine neue Runde anlegen und keinen Wait-Loop starten. Übersetze `Subagent-Qualität` in die beste verfügbare Modell-/Reasoning-Einstellung deines Tools:

- `Inherit`: keine Modell- oder Reasoning-Overrides setzen.
- `Balanced`: mittlere Qualität/Kosten wählen, falls möglich.
- `High`: stärkste sinnvoll verfügbare Qualität wählen, falls möglich.
- `Role-based`: These mit Balanced, Antithese und Synthese mit High ausführen, falls möglich.

Wenn dein Tool keine Subagent-Qualitätswahl erlaubt, ist das kein Fehler; verwende faktisch `Inherit`.

Wenn `Step-Ausführung: inline` gilt: Erledige den Schritt direkt in der Hauptsession.

- **These**: Bei `file`: Lies `rounds/round_NN/artifact.md`; bei `directory`: lies `rounds/round_NN/artifact/`. Falls `NN > 1`, lies zusätzlich den Übergabeimpuls der Vorrunde (`rounds/round_{NN-1}/step_3_handoff.md`). Schreibe bei `file` nach `step_1_thesis.md`, bei `directory` nach `step_1_thesis/`, und immer nach `step_1_handoff.md`.
- **Antithese**: Bei `file`: Lies `artifact.md`, `step_1_thesis.md` und `step_1_handoff.md`; bei `directory`: lies `artifact/`, `step_1_thesis/` und `step_1_handoff.md`. Schreibe immer nach `step_2_antithesis.md` und `step_2_handoff.md`. Auch bei Directory-Artefakten bleibt die Antithese eine Markdown-Datei, weil sie keine neue Artefaktfassung erzeugt, sondern strukturierte Kritik.
- **Synthese**: Lies `step_1_thesis` (Datei oder Verzeichnis), `step_2_antithesis.md` und `step_2_handoff.md`. Schreibe bei `file` nach `step_3_synthesis.md`, bei `directory` nach `step_3_synthesis/`, und immer nach `step_3_handoff.md`.

Befolge dabei zwingend die Rollen-Definitionen aus `CHALLENGE.md`.

### Schritt 3: State und ggf. neue Runde aktualisieren

- Aktualisiere `state.md`: Schritt-Status, `Dran:`, Verlauf.
- **Falls du gerade Schritt 3 (Synthese) erledigt hast** UND die aktuelle Runde < Gesamtrundenzahl ist:
  - Lege `rounds/round_{NN+1}/` an
  - Bei `Artifact-Typ: file`: Kopiere `step_3_synthesis.md` nach `rounds/round_{NN+1}/artifact.md`
  - Bei `Artifact-Typ: directory`: Kopiere `step_3_synthesis/` nach `rounds/round_{NN+1}/artifact/`
  - Belasse `step_3_handoff.md` im abgeschlossenen Rundenordner; die These der nächsten Runde liest ihn dort als Übergabeimpuls.
  - Inkrementiere die Runden-Nummer in `state.md`
  - Setze `Dran:` und Rolle laut Rotationsplan für die neue Runde
- **Falls du gerade Schritt 3 der letzten Runde erledigt hast**:
  - Setze in `state.md` den Status auf `completed`
  - Bei `Artifact-Typ: file`: Kopiere `step_3_synthesis.md` nach `sparring/FINAL_ARTIFACT.md`
  - Bei `Artifact-Typ: directory`: Kopiere `step_3_synthesis/` nach `sparring/FINAL_ARTIFACT/`

### Schritt 4: Wait-Loop starten

Wie im INIT-Modus Schritt 7. Falls dieser Agent zum ersten Mal ins Sparring einsteigt: kein Hinweis an den User mehr nötig, der erste Hinweis kam vom Initiator.

## Reaktion auf watch_loop

Der Bash-Loop blockiert und beendet sich mit drei möglichen Exit-Codes. Reagiere konkret:

| Exit | Output enthält | Reaktion |
|------|----------------|----------|
| 0 | `WAKE:` und state.md-Inhalt | Du bist wieder dran. Gehe zu JOIN-Modus Schritt 2 (deinen Schritt erledigen). Danach erneut watch_loop aufrufen. |
| 1 | `DONE:` | Alle gewählten Runden durch. Melde dem User: *"Sparring abgeschlossen — finales Artefakt liegt in `sparring/FINAL_ARTIFACT.md` bzw. `sparring/FINAL_ARTIFACT/`."* Beende sauber, kein neuer Loop. |
| 2 | `TIMEOUT:` | Der andere Agent hat sich 30 Min nicht gemeldet. Frage den User: *"{OTHER_NAME} meldet sich seit 30 Min nicht. Weiter warten, oder Sparring pausieren?"* Bei "weiter": watch_loop erneut starten. |

## Wichtige Verhaltensregeln

- **Nicht den Inhalt bewerten** — der Skill befolgt nur den Prozess. Die Rollen in CHALLENGE.md geben vor, wie zu denken ist (radikal hinterfragen, integrieren ohne Kompromiss usw.). Verlass dich darauf.
- **state.md ist die einzige Wahrheit** — vor jeder Aktion erneut lesen. Kein Caching im Kopf.
- **Niemals Schritte überspringen** oder mehrere Schritte in einer Aktivierung erledigen. Pro Aufwachen genau ein Schritt, dann zurück in den Loop.
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
