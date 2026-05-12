---
name: text-sparring
description: Set up an autonomous multi-agent text sparring loop where two AI agents (typically Claude + Codex/ChatGPT) iteratively refine a text artifact over 10 rounds using Thesis → Antithesis → Synthesis. Use this skill whenever the user wants two agents to "spar" over a text, mutually challenge or refine a draft, or run a dialectical improvement loop. Trigger on requests like "starte ein Text-Sparring", "lass zwei Agenten meinen Text gegenseitig schärfen", "richte einen dialektischen Loop ein", "set up a text sparring", "I want Claude and Codex to spar on this draft", or any mention of "Text-Sparring", "Agent-Sparring", "Multi-Agent-Refinement". Also trigger when an agent is asked to JOIN an existing sparring ("steig ins Sparring ein", "join the running sparring", "Codex, übernimm Schritt 2"). The skill is harness-agnostic — works in Claude Code, Cowork, and Codex CLI — and requires no external tools beyond bash and standard Unix utilities.
---

# Text Sparring

Ein harness-agnostischer Skill zum Aufsetzen und Mitwirken an einem **Text-Sparring zwischen zwei AI-Agenten**. Zwei Agenten (z. B. Claude + Codex) durchlaufen 10 Runden mit den Rollen **These → Antithese → Synthese**, wobei beide Agenten alle Rollen in Vollrotation durchlaufen.

Es geht **nicht ums Gewinnen**, sondern um gegenseitiges Schärfen — wie zwei Sparringspartner im Training. Der Skill kennt keinen Inhalt; er orchestriert nur den **Prozess**. Der zu sparrende Text liegt außerhalb des Skills im Projektverzeichnis.

## Wann triggern

Triggere diesen Skill in zwei Situationen:

1. **INIT** — Der User möchte ein neues Sparring starten ("Lass meinen Text sparren", "Setup Text-Sparring für draft.md").
2. **JOIN** — Der User sagt einem zweiten Agent, dass er in ein laufendes Sparring einsteigen soll ("Steig ins Sparring ein", "Codex, übernimm").

Erkenne den Modus automatisch: Existiert `sparring/state.md` im aktuellen Projektverzeichnis → JOIN. Ansonsten → INIT.

## INIT-Modus (erste Aktivierung)

### Schritt 1: Interview

Stelle dem User exakt diese Fragen — eine nach der anderen, kompakt:

1. **Welchen Text soll ich sparren?** Erwarte einen Dateipfad (z. B. `draft.md`, `texte/kapitel_03.md`).
2. **Welches zweite Tool kommt rein?** Optionen: `Codex CLI`, `ChatGPT (Web)`, `Cowork`, `andere Claude Code Session`. Frag nach dem Namen, wie er später in `state.md` referenziert werden soll (z. B. "Codex", "GPT-5").
3. **Mein eigener Name im Sparring?** Default: `Claude`. Akzeptiere Abweichungen.

### Schritt 2: Scaffolding anlegen

Lege im aktuellen Projektverzeichnis (NICHT im Skill-Verzeichnis) folgende Struktur an:

```
sparring/
├── CHALLENGE.md
├── state.md
├── watch_loop.sh
├── chatgpt_codex_instructions.md
└── rounds/
    └── round_01/
        └── artifact.md          ← Kopie des Ausgangstexts
```

Vorgehen:

- Lies `templates/CHALLENGE.md.tpl` und ersetze die Platzhalter mit den konkreten Agent-Namen und dem unten beschriebenen Rotationsplan. Schreibe das Ergebnis nach `sparring/CHALLENGE.md`.
- Lies `templates/state.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/state.md`. Setze den initialen Status auf: Runde 1, Schritt 1, dran ist der **Initiator** (also du selbst), Rolle ist **These**.
- Kopiere `templates/watch_loop.sh` 1:1 nach `sparring/watch_loop.sh`. Mache sie nicht ausführbar — sie wird mit `bash watch_loop.sh ...` aufgerufen.
- Lies `templates/chatgpt_codex_instructions.md`, befülle die Platzhalter mit dem Projektpfad und dem Namen des zweiten Agents, schreibe nach `sparring/chatgpt_codex_instructions.md`.
- Kopiere den vom User benannten Ausgangstext nach `sparring/rounds/round_01/artifact.md`.

### Schritt 3: CLAUDE.md erweitern (nur wenn du Claude bist)

Falls eine `CLAUDE.md` im Projektroot existiert: hänge den Inhalt von `templates/claude_md_snippet.md` am Ende an. Falls keine existiert: lege eine neue mit diesem Inhalt an.

Ersetze im Snippet die Platzhalter `{MY_NAME}` und `{OTHER_NAME}` mit den konkreten Werten aus dem Interview.

### Schritt 4: Rotationsplan generieren

Der Plan ist **fest und deterministisch** — er gilt für jedes Setup gleich, nur die Namen werden eingesetzt. Verwende exakt diese Tabelle (A = Initiator, B = zweiter Agent):

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

Diese Verteilung ist exakt ausbalanciert: jeder Agent macht jede Rolle genau 5× über 10 Runden.

Schreibe sie in `state.md` mit den echten Namen statt A/B.

### Schritt 5: Schritt 1 (These der Runde 1) selbst erledigen

Lies `sparring/rounds/round_01/artifact.md` und produziere die These gemäß den Regeln in `CHALLENGE.md`. Schreibe nach `sparring/rounds/round_01/step_1_thesis.md`.

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

Falls `Dran:` nicht **dich** zeigt: melde *"Im laufenden Sparring ist gerade {OTHER} dran, nicht ich. Soll ich trotzdem in den Wait-Loop gehen und warten, bis ich dran bin?"* — auf User-Bestätigung dann Schritt 4 (Wait-Loop) ohne vorherige Arbeit.

### Schritt 2: Deinen Schritt erledigen

- **These**: Lies `rounds/round_NN/artifact.md`, schreibe nach `step_1_thesis.md`
- **Antithese**: Lies `rounds/round_NN/step_1_thesis.md` (und `artifact.md` als Bezug), schreibe nach `step_2_antithesis.md`
- **Synthese**: Lies sowohl `step_1_thesis.md` als auch `step_2_antithesis.md`, schreibe nach `step_3_synthesis.md`

Befolge dabei zwingend die Rollen-Definitionen aus `CHALLENGE.md`.

### Schritt 3: State und ggf. neue Runde aktualisieren

- Aktualisiere `state.md`: Schritt-Status, `Dran:`, Verlauf.
- **Falls du gerade Schritt 3 (Synthese) erledigt hast** UND die aktuelle Runde < 10 ist:
  - Lege `rounds/round_{NN+1}/` an
  - Kopiere `step_3_synthesis.md` nach `rounds/round_{NN+1}/artifact.md`
  - Inkrementiere die Runden-Nummer in `state.md`
  - Setze `Dran:` und Rolle laut Rotationsplan für die neue Runde
- **Falls du gerade Schritt 3 der Runde 10 erledigt hast**:
  - Setze in `state.md` den Status auf `completed`
  - Kopiere `step_3_synthesis.md` nach `sparring/FINAL_ARTIFACT.md`

### Schritt 4: Wait-Loop starten

Wie im INIT-Modus Schritt 7. Falls dieser Agent zum ersten Mal ins Sparring einsteigt: kein Hinweis an den User mehr nötig, der erste Hinweis kam vom Initiator.

## Reaktion auf watch_loop

Der Bash-Loop blockiert und beendet sich mit drei möglichen Exit-Codes. Reagiere konkret:

| Exit | Output enthält | Reaktion |
|------|----------------|----------|
| 0 | `WAKE:` und state.md-Inhalt | Du bist wieder dran. Gehe zu JOIN-Modus Schritt 2 (deinen Schritt erledigen). Danach erneut watch_loop aufrufen. |
| 1 | `DONE:` | Alle 10 Runden durch. Melde dem User: *"Sparring abgeschlossen — finales Artefakt liegt in `sparring/FINAL_ARTIFACT.md`."* Beende sauber, kein neuer Loop. |
| 2 | `TIMEOUT:` | Der andere Agent hat sich 30 Min nicht gemeldet. Frage den User: *"{OTHER_NAME} meldet sich seit 30 Min nicht. Weiter warten, oder Sparring pausieren?"* Bei "weiter": watch_loop erneut starten. |

## Wichtige Verhaltensregeln

- **Nicht den Inhalt bewerten** — der Skill befolgt nur den Prozess. Die Rollen in CHALLENGE.md geben vor, wie zu denken ist (radikal hinterfragen, integrieren ohne Kompromiss usw.). Verlass dich darauf.
- **state.md ist die einzige Wahrheit** — vor jeder Aktion erneut lesen. Kein Caching im Kopf.
- **Niemals Schritte überspringen** oder mehrere Schritte in einer Aktivierung erledigen. Pro Aufwachen genau ein Schritt, dann zurück in den Loop.
- **Bei Konflikten**: Wenn state.md inkonsistent wirkt (z. B. Verlauf sagt Schritt 2 fertig, aber Datei fehlt), melde es dem User statt zu raten.

## Dateien in diesem Skill

| Datei | Zweck |
|-------|-------|
| `templates/CHALLENGE.md.tpl` | Regelwerk + Rollen-Definitionen + Rotationsplan-Schema |
| `templates/state.md.tpl` | Status-Datei mit Platzhaltern |
| `templates/claude_md_snippet.md` | Anhang für CLAUDE.md im Projekt |
| `templates/chatgpt_codex_instructions.md` | Instructions für den zweiten Agent (Custom Instructions o. Ä.) |
| `templates/watch_loop.sh` | Bash-Polling-Script, pure POSIX |
| `templates/round_artifact.md.tpl` | (Reserve, derzeit ungenutzt — Ausgangstext wird direkt kopiert) |

Platzhalter in den Templates haben die Form `{NAME}` und werden beim Scaffolding ersetzt.
