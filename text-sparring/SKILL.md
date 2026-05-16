---
name: text-sparring
description: Set up an autonomous multi-agent text sparring loop where two AI agents iteratively refine a text artifact over configurable rounds using Thesis → Antithesis → Synthesis, with optional dialectical quality measurement per round. Multiple sparrings per project are supported via named subfolders under `sparring/`. Use this skill whenever the user wants two agents to "spar" over a text, mutually challenge or refine a draft, or run a dialectical improvement loop. Trigger on requests like "starte ein Text-Sparring", "lass zwei Agenten meinen Text gegenseitig schärfen", "richte einen dialektischen Loop ein", "set up a text sparring", "let two agents spar on this draft", or any mention of "Text-Sparring", "Agent-Sparring", "Multi-Agent-Refinement". Also recognize a turbo/quick-start variant ("Turbo-Modus", "Schnellstart", "ohne Fragen", "auto-init") that skips the interview and applies AI-generated defaults. Also trigger when an agent is asked to JOIN an existing sparring ("steig ins Sparring ein", "steig ins Sparring <name> ein", "join the running sparring", "übernimm Schritt 2"). Also trigger on RESIZE requests that change the total round count of an existing sparring — either lengthening ("verlängere das Sparring um 3 Runden", "Sparring <name> auf 8 Runden erweitern", "extend sparring <name> by 3 rounds") or shortening ("verkürze Sparring <name> auf 5 Runden", "kürze um 2 Runden", "Sparring nach Runde 5 beenden", "shorten sparring <name> to 5 rounds"). The skill is harness-agnostic and requires no external tools beyond bash and standard Unix utilities.
---

# Text Sparring

Ein harness-agnostischer Skill zum Aufsetzen und Mitwirken an einem **Text-Sparring zwischen zwei AI-Agenten**. Zwei Agenten durchlaufen eine konfigurierbare Anzahl von Runden mit den Rollen **These → Antithese → Synthese**.

Es geht **nicht ums Gewinnen**, sondern um gegenseitiges Schärfen — wie zwei Sparringspartner im Training. Der Skill kennt keinen Inhalt; er orchestriert nur den **Prozess**. Der zu sparrende Text liegt außerhalb des Skills im Projektverzeichnis.

## Skill-Isolation (Single-Skill-Modus)

Solange du in diesem Skill bist — egal ob in INIT, JOIN, als Step-Worker oder im Wait-Loop — **aktiviere keine anderen Skills automatisch**. Auch nicht `brainstorming`, `test-driven-development`, `systematic-debugging`, `using-superpowers`, `writing-plans`, `executing-plans`, `subagent-driven-development` oder andere Workflow-/Helfer-Skills, die sich evtl. aufdrängen. Das Sparring orchestriert sich vollständig selbst über `state.md`, `CHALLENGE.md` und die Step-Kontexte — jede zusätzliche Skill-Aktivierung erzeugt Overkill (doppelte Pläne, Brainstorming-Sessions, TDD-Schleifen) und bricht die Single-Step-Pro-Aufwachen-Regel.

**Ausnahme:** Der User nennt einen anderen Skill **in seinem aktuellen Prompt explizit** (z. B. *"Nutze TDD beim Synthese-Schritt"*). Dann darfst du diesen einen Skill für genau diesen Schritt verwenden.

Diese Isolation gilt auch für Subagents: Step-Kontexte enthalten eine entsprechende Klausel.

## Wann triggern

Triggere diesen Skill in zwei Situationen:

1. **INIT** — Der User möchte ein neues Sparring starten ("Lass meinen Text sparren", "Setup Text-Sparring für draft.md").
2. **JOIN** — Der User sagt einem zweiten Agent, dass er in ein laufendes Sparring einsteigen soll ("Steig ins Sparring ein", "Codex, übernimm").

### Notation in diesem Skill

Jedes Sparring lebt in einem benannten Unterordner unter `sparring/`, zum Beispiel `sparring/readme-v1/`. In diesem Skill steht `<NAME>` als Platzhalter für diesen Slug. **Ersetze `<NAME>` immer durch den konkreten Slug aus dem Interview (INIT-Modus) bzw. aus dem erkannten aktiven Sparring (JOIN-Modus).** Das übergeordnete `sparring/` ist der Container für alle Sparrings in diesem Projekt.

### Modus-Erkennung

Erkenne den Modus automatisch:

- **Trigger-Phrase enthält Pre-Check-Schlüsselwörter** — `pre-check`, `precheck`, `sparring check`, `lohnt sich sparring`, `sparring-check`, EN: `pre-check sparring`, `is sparring worth`, `sparring worth it` → **Pre-Check-Modus**. Siehe Pre-Check-Modus unten. Dieser Modus hat Vorrang vor allen anderen (auch wenn ein laufendes Sparring existiert — der Pre-Check legt nur eine `precheck.md` an und kollidiert nicht mit laufendem State, prüft das aber explizit).
- **Trigger-Phrase enthält Resize-Schlüsselwörter** — Erweiterung (`verlängere`/`verlängern`, `erweitere`/`erweitern auf`, `extend`/`extend by`, `noch X Runden`, `weitere X Runden`, `fortsetzen mit X Runden`) oder Verkürzung (`verkürze`/`kürzen auf`, `kürze um`, `shorten`/`shorten to`, `nach Runde X beenden`, `auf X Runden reduzieren`) → **RESIZE-Modus** für das genannte (oder einzig plausible) Sparring. Siehe RESIZE-Modus unten.
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

### Turbo-Modus

Wenn die Trigger-Phrase des Users Worte wie **"Turbo"**, **"Schnellstart"**, **"ohne Fragen"**, **"auto"** oder **"quick"** im INIT-Kontext enthält (z. B. *"Starte ein Text-Sparring im Turbo-Modus über draft.md"*), überspringe das Interview komplett:

0. **Pre-Check ausführen** (inline, vor allem Weiteren): Führe Pre-Check-Modus Schritte 1, 2, 6, 7 aus (Artefakt parsen, Slug ableiten, Sparring-Typ ableiten, `precheck.md` schreiben). Überspringe in Turbo den State-Konflikt-Check (Schritt 3) und das Precheck-Existiert-Handling (Schritt 4) — Turbo legt das Sparring sowieso an und überschreibt eine ggf. existierende `precheck.md` beim Re-Run. Lies die finale Empfehlung aus der erzeugten `precheck.md` und merke sie als `precheck_rounds`.
1. Sieh dir das Projektverzeichnis an (wie unten beschrieben).
2. Generiere konkrete Vorschläge für alle 10 Interview-Punkte aus Projektkontext und Praxis-Defaults (gleiche Logik wie unten, nur ohne den User zu fragen). **Measurement (Frage 10) ist im Turbo-Modus per Default `Off`**; nur wenn die Trigger-Phrase explizit "mit Messung", "with measurement", "mit Qualitätsmessung" o.ä. enthält, setze `On` mit `Measurement-Qualität: High`. **Frage 7 (Anzahl Runden):** Übernimm `precheck_rounds` als Default, außer der User hat in der Trigger-Phrase explizit eine andere Zahl genannt (dann gewinnt die User-Zahl, die `precheck.md` bleibt aber als Nachvollziehbarkeit liegen).
3. Wenn die Trigger-Phrase einen konkreten Artefaktpfad enthält, nimm den; sonst leite ihn aus dem Projektkontext ab.
4. **Bei `precheck_rounds == 0`** (Sparring nicht empfohlen) UND keine User-Zahl in der Trigger-Phrase: Gib dem User die Empfehlung in 2–3 Zeilen (Score + Veto-Begründung + Pfad zur `precheck.md`) und frage einmal nach: *"Trotzdem starten? Wenn ja, mit wievielen Runden? (Empfehlung im Skipping-Fall: 3, oder Abbruch)"*. Bei Abbruch: stoppe, kein Scaffolding. Bei Bestätigung mit Rundenzahl: weiter mit dieser Zahl statt `precheck_rounds`.
5. Fasse die gewählte Konfiguration in 4–6 Zeilen zusammen und sage dem User in einem Satz, dass du jetzt loslegst.
6. Lege direkt das Scaffolding an, führe (falls `Measurement: on`) Schritt 4.5 (Baseline-Measurement) aus, und erledige Schritt 1 (These) — ohne weitere Rückfrage.
7. Gib am Ende den Handover-Prompt für den zweiten Agenten aus (siehe Schritt 7) und starte den Wait-Loop.

**Ausnahme:** Wenn du für einen einzelnen Punkt keinen vertretbaren Default ableiten kannst (z. B. mehrere gleichwertige Artefakt-Kandidaten und keiner in der Trigger-Phrase, oder der Name des zweiten Tools ist nicht erkennbar), frag **nur diese eine Frage** zurück und mach dann mit dem Rest direkt weiter. Kein vollständiges Interview.

Im Zweifel zugunsten der Geschwindigkeit entscheiden — der User kann das Sparring jederzeit abbrechen und neu starten.

### Schritt 1: Interview

**Vor dem Interview:** Sieh dir das aktuelle Projektverzeichnis kurz an (Top-Level-Dateien und -Ordner, ggf. eine `README.md` oder `CLAUDE.md`). Das ist die Grundlage für deine konkreten Vorschläge unten — du musst sie nicht im Detail lesen, nur Kontext sammeln.

**Format pro Frage:** Stelle die Frage, gib einen **konkreten Vorschlag** und eine **knappe Begründung in 1 Satz** (worauf basiert der Vorschlag — Artefakt, Projektkontext, Praxis-Erfahrung). Dann warte auf Bestätigung oder Korrektur. Eine Frage nach der anderen, nicht alles auf einmal.

Beispielformat:

> *"**Welches Artefakt?** — Ich schlage `README.md` vor. Begründung: das ist die einzige Markdown-Datei im Root und sieht nach dem Hauptartefakt aus. Passt das, oder soll es etwas anderes sein?"*

Hier die Fragen plus, woraus du den Vorschlag jeweils ableitest:

1. **Welches Artefakt soll gechallenged werden?** Schlage konkret eine Datei oder ein Verzeichnis vor, das du im Projekt siehst (z. B. die einzige Top-Level-Markdown-Datei, ein offensichtliches `docs/`, ein `text-sparring/`-Bundle). Wenn mehrere plausibel sind, nenne 2–3 Kandidaten und empfiehl einen. Wenn nichts Naheliegendes da ist, frag offen nach einem Pfad.
2. **Wie soll dieses Sparring heißen?** Leite einen Slug aus dem Artefakt-Basename ab (z. B. `draft.md` → `draft`, `text-sparring/` → `text-sparring`). Falls unter `sparring/` schon ein gleichnamiger Ordner existiert, hänge automatisch einen aufsteigenden Suffix `-v2`, `-v3` an und schlage diesen Namen vor. Normalisiere User-Eingaben vor dem Anlegen: nur Kleinbuchstaben, Ziffern, Bindestriche; Leerzeichen und Unterstriche werden zu `-`; sonstige Sonderzeichen entfernt. Zeige den finalen Slug zur Bestätigung. Im weiteren Verlauf heißt dieser Slug `<NAME>`.
3. **Welche Projektkontext-Dateien gelten?** Scanne das Projektverzeichnis und nahe Unterordner aktiv nach Dokumenten, die Constraints, Stil, Zielgruppe, Längenvorgaben, Tonalität oder Brand Voice enthalten könnten. Suchmuster (case-insensitive, DE/EN): `*redaktionsplan*`, `*editorial*`, `*style[-_ ]guide*`, `*styleguide*`, `*briefing*`, `*brief.md`, `*brand[-_ ]voice*`, `*tone[-_ ]of[-_ ]voice*`, `*content[-_ ]strategy*`, `*personas*`, `*post[-_ ]guidelines*`, `*messaging*`, `*positioning*`. Bei `Sparring-Typ: Campaign` zusätzlich Redaktions-/Kanal-Dokumente; bei `Skill` zusätzlich Schreib-/Prompt-Guidelines; bei `Code` zusätzlich `CONTRIBUTING.md`/Coding-Conventions. Schlage die gefundenen Dateien als Liste relativer Pfade vor, jeweils mit einer halbsatzigen Begründung. Der User bestätigt, streicht oder ergänzt. Default: leer, wenn nichts Passendes gefunden — nicht raten. Diese Dateien werden in `artifact.md` unter `Projektkontext` als **referenzierte** Pfade eingetragen (nicht kopiert); die Agenten lesen sie zur Step-Laufzeit live, damit Updates am Redaktionsplan auch laufende Sparrings erreichen.
4. **Welches zweite Tool kommt rein?** Optionen: `Codex CLI`, `ChatGPT (Web)`, `Cowork`, `andere Claude Code Session`. Empfiehl als Default `Codex CLI` oder `andere Claude Code Session` mit der Begründung, dass beide vollautonom laufen (Wait-Loop funktioniert). `ChatGPT (Web)` nur erwähnen, wenn der User explizit kein lokales Tool hat. Frag dann nach dem Namen, wie er später in `state.md` stehen soll (z. B. "Codex", "GPT-5").
5. **Mein eigener Name im Sparring?** Schlage `Claude` vor, weil das die naheliegende Default-Bezeichnung für dieses Tool ist. Akzeptiere jede Abweichung.
6. **Sparring-Typ?** Untersuche kurz das Artefakt und schlage konkret einen der vier Typen vor (`Text`, `Campaign`, `Skill`, `Code`) statt nur `Auto`. Begründung soll auf dem Artefakt basieren: README/Essay → `Text`, Post-Sammlung → `Campaign`, SKILL.md mit Templates → `Skill`, Quellcode-Verzeichnis → `Code`. Wenn unklar, nimm `Auto` und sage warum.
7. **Wie viele Runden?** Schlage je nach Kontext konkret eine Zahl vor:
   - Schnelltest oder neues Setup ausprobieren → `3`
   - Realer Verbesserungsdurchlauf bei mittellangem Artefakt → `5`
   - Tiefe Schärfung eines wichtigen Artefakts → `10`
   Begründung soll auf Artefaktgröße und User-Ziel basieren.
8. **Ausführungsmodus?** Schlage `Subagent` vor, wenn du in einer Umgebung läufst, die Subagents erkennbar unterstützt (z. B. Claude Code mit Task-Tool). Sonst `Inline`. `Auto` nur dann, wenn du dir nicht sicher bist. Begründung: Subagent isoliert Step-Kontexte sauberer und vermeidet Rollenvermischung.
   - `Auto`: Subagent verwenden, wenn das aktuelle Tool das erkennbar unterstützt; sonst inline.
   - `Subagent`: jeden Schritt in einem frischen Subagent-Kontext ausführen. Wenn das aktuelle Tool das nicht kann, stoppen und den User fragen.
   - `Inline`: Schritte direkt in der Hauptsession ausführen.
9. **Subagent-Qualität?** Schlage in der Regel `Inherit` vor (Begründung: keine unnötigen Overrides, Subagent läuft auf gleichem Modell wie Hauptsession). Wenn das Artefakt besonders wichtig ist oder der User Qualität betont, schlage `High` oder `Role-based` vor.
   - `Inherit`: Subagents übernehmen Modell/Qualität der Hauptsession; keine expliziten Overrides setzen.
   - `Balanced`: mittlere Qualität/Kosten, wenn das Tool eine Qualitätswahl erlaubt.
   - `High`: stärkste sinnvoll verfügbare Qualität, wenn das Tool eine Qualitätswahl erlaubt.
   - `Role-based`: These eher Balanced, Antithese und Synthese eher High.
10. **Messung aktivieren?** Schlage `Off` als Default vor mit folgender Begründung: Measurement gibt nach jeder Runde einen deskriptiven Delta-Score (5 Dimensionen, 1-5 Skala) plus kumulative Trendzahl gegen das Original — als Anhaltspunkt, wieviel das Sparring gebracht hat. Kostet bei 5 Runden ca. 11 zusätzliche Evaluator-Subagent-Aufrufe in High-Qualität. Lohnt sich für wichtige Artefakte; bei Schnelltests eher aus. Werte: `On` / `Off`. Bei `On` Folgefrage nach `Measurement-Qualität`:
    - `Inherit`: Evaluator übernimmt Qualität der Hauptsession; keine Overrides.
    - `Balanced`: mittlere Qualität, wenn das Tool eine Qualitätswahl erlaubt.
    - `High` (Default bei `On`): stärkste sinnvoll verfügbare Qualität; Bewertung profitiert von Reasoning.
    - `xHigh`: nur wenn das Tool ein noch stärkeres Profil bietet.

    Bei `Off` bleibt das Feld `Measurement-Qualität` in state.md auf `-`.

Nach allen 10 Antworten fasse die Konfiguration in 4–6 Zeilen zusammen und hol dir ein finales "Los" vom User, bevor du das Scaffolding anlegst.

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
- Lies `templates/artifact.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/<NAME>/artifact.md`. Setze `Initiale Kopie` auf `sparring/<NAME>/rounds/round_01/artifact.md` bei Dateien oder `sparring/<NAME>/rounds/round_01/artifact/` bei Verzeichnissen. Trage die im Interview bestätigten Projektkontext-Pfade als Bulletliste unter `Projektkontext` ein (relative Pfade vom Projekt-Root). Wenn keiner bestätigt wurde: Sektion mit dem Hinweis `(keine)` befüllen, nicht weglassen.
- Lies `templates/state.md.tpl`, befülle die Platzhalter, schreibe nach `sparring/<NAME>/state.md`. Setze `Sparring-Name` auf `<NAME>`. Setze den initialen Status auf: Runde 1 von gewählter Gesamtrundenzahl, Schritt 1, dran ist der **Initiator** (also du selbst), Rolle ist **These**. Setze `Artifact-Typ`, `Artifact-Pfad`, `Sparring-Typ`, `Erkannter Sparring-Typ`, `Ausführungsmodus`, `Step-Ausführung`, `Subagent-Qualität`, `Measurement` (`on` oder `off`) und `Measurement-Qualität` (bei `Measurement: off` setze `-`).
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

### Schritt 4.5: Baseline-Measurement (nur wenn `Measurement: on`)

Wenn `Measurement: off` gilt, überspringe diesen Schritt komplett.

Wenn `Measurement: on` gilt, lasse einen neutralen Evaluator-Subagent eine einmalige Eingangs-Bewertung des Originalartefakts erstellen, **bevor** Schritt 5 (These Runde 1) startet:

1. Wähle die passende Rubric-Datei anhand von `Erkannter Sparring-Typ`:
   - `Text` → `templates/measurement_rubric_text.md`
   - `Campaign` → `templates/measurement_rubric_campaign.md`
   - `Skill` → `templates/measurement_rubric_skill.md`
   - `Code` → `templates/measurement_rubric_code.md`
2. Erzeuge `sparring/<NAME>/context/baseline_measurement_prompt.md` aus `templates/measurement_context.md.tpl`. Platzhalter:
   - `{MEASUREMENT_TYPE}` = `baseline`
   - `{MEASUREMENT_TYPE_LABEL}` = `Baseline`
   - `{SPARRING_NAME}`, `{SPARRING_PATH}` = entsprechend
   - `{RESOLVED_SPARRING_TYPE}`, `{ARTIFACT_TYPE}` = aus state.md
   - `{RUBRIC_PATH}` = die gewählte Rubric (z. B. `text-sparring/templates/measurement_rubric_text.md`)
   - `{INPUT_FILES}` = bei `file`: `sparring/<NAME>/rounds/round_01/artifact.md` plus `sparring/<NAME>/artifact.md`; bei `directory`: `sparring/<NAME>/rounds/round_01/artifact/` plus `sparring/<NAME>/artifact.md`
   - `{INPUT_ARTIFACT_LABEL}` = `Original (rounds/round_01/artifact)`
   - `{OUTPUT_FILE}` = `sparring/<NAME>/rounds/round_01/measurement_baseline.md`
3. Beauftrage einen frischen Subagent/Worker/Workstream mit genau diesem Kontext, in der durch `Measurement-Qualität` bestimmten Modell-/Reasoning-Stufe. Wenn das Tool keine Subagent-Qualitätswahl erlaubt: verwende faktisch `Inherit`.
4. Warte auf Abschluss und prüfe, dass `sparring/<NAME>/rounds/round_01/measurement_baseline.md` existiert.
5. Lies den Mittelwert und die Einzelscores aus der Datei und gib dem User einen 2-Zeiler aus, z. B.: *"Baseline-Score: ⌀ 2.7 (Integrative Complexity 2.5, Argumentation 3.0, Idea Density 2.5, Klarheit 3.0, Constraint-Treue 2.5). Starte jetzt Runde 1."*
6. Ergänze in `state.md` einen Verlauf-Eintrag: *"Baseline-Measurement: ⌀ x.x"*.

Wenn der Evaluator-Subagent stattdessen einen Inkonsistenz-Hinweis liefert (z. B. fehlende Inputs): melde das dem User, schreibe Schritt 5 noch nicht und kein Wait-Loop. Kein stiller Fallback.

### Schritt 5: Schritt 1 (These der Runde 1) erledigen

Wenn `Step-Ausführung: subagent` gilt: Erzeuge zuerst `sparring/<NAME>/context/round_01_step_1_prompt.md` aus `templates/step_context.md.tpl` (mit `{SPARRING_PATH}` = `sparring/<NAME>`), beauftrage einen frischen Subagent/Worker/Workstream mit genau diesem Kontext, warte auf Abschluss und prüfe, dass `sparring/<NAME>/rounds/round_01/step_1_thesis.md` (bzw. `.../step_1_thesis/`) und `sparring/<NAME>/rounds/round_01/step_1_handoff.md` existieren.

Wenn `Step-Ausführung: inline` gilt: Lies bei `Artifact-Typ: file` `sparring/<NAME>/rounds/round_01/artifact.md`; lies bei `Artifact-Typ: directory` `sparring/<NAME>/rounds/round_01/artifact/`. Produziere die These gemäß den Regeln in `sparring/<NAME>/CHALLENGE.md`. Schreibe bei `file` nach `sparring/<NAME>/rounds/round_01/step_1_thesis.md`, bei `directory` nach `sparring/<NAME>/rounds/round_01/step_1_thesis/`, und den Übergabeimpuls immer nach `sparring/<NAME>/rounds/round_01/step_1_handoff.md`.

### Schritt 6: state.md aktualisieren

Setze in `sparring/<NAME>/state.md`:
- Aktueller Schritt-Status: ✅ Schritt 1 erledigt
- `Dran:` auf den zweiten Agent (Name aus Interview)
- Aktualisiere die Verlauf-Sektion

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
>
> Wichtig: Arbeite im Single-Skill-Modus der text-sparring-Skill.
> Aktiviere keine anderen Skills automatisch (kein brainstorming,
> kein TDD, kein systematic-debugging, kein using-superpowers etc.),
> auch wenn sie sich aufdrängen. Das Sparring orchestriert sich
> selbst.
> ````

Setze die Platzhalter `{OTHER_NAME}`, `<NAME>` und `{PROJECT_PATH}` mit den konkreten Werten ein, bevor du den Block ausgibst. Der innere Codeblock (mit den vier Backticks außen) muss exakt diese Form behalten, damit der User ihn als einen Block markieren und kopieren kann.

Führe danach aus: `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"`.

Ab Aufruf des Loops gilt Silent Wait Mode: Keine Zwischenkommentare, keine Statusmeldungen, keine Spekulation über den anderen Agenten. Erst wieder reagieren, wenn `watch_loop.sh` mit WAKE, DONE oder TIMEOUT endet.

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

### Schritt 2.5: Measurement nach Synthese (nur wenn `Measurement: on` UND der eben erledigte Step war die Synthese)

Wenn `Measurement: off` ODER der gerade erledigte Step war nicht die Synthese (Round-Step 3), überspringe diesen Schritt komplett.

Andernfalls führt die Hauptsession **vor** dem State-Update (Schritt 3) zwei zusätzliche Evaluator-Subagent-Aufrufe aus. Beide nutzen `templates/measurement_context.md.tpl` und die Rubric, die zum `Erkannter Sparring-Typ` passt (siehe Schritt 4.5 für die Rubric-Auswahl).

**2.5a — Round-Delta-Measurement:**

1. Erzeuge `sparring/<NAME>/context/round_NN_measurement_round_prompt.md` aus `templates/measurement_context.md.tpl`. Platzhalter:
   - `{MEASUREMENT_TYPE}` = `round_delta`
   - `{MEASUREMENT_TYPE_LABEL}` = `Round-Delta`
   - `{ROUND}` = `NN`
   - `{INPUT_FILES}` = bei `file`: `sparring/<NAME>/rounds/round_NN/artifact.md` (=Pre) und `sparring/<NAME>/rounds/round_NN/step_3_synthesis.md` (=Post) plus `sparring/<NAME>/artifact.md`; bei `directory`: die Verzeichnis-Varianten.
   - `{PRE_LABEL}` = `Runden-Input (rounds/round_NN/artifact)`
   - `{POST_LABEL}` = `Synthese der Runde NN (rounds/round_NN/step_3_synthesis)`
   - `{OUTPUT_FILE}` = `sparring/<NAME>/rounds/round_NN/measurement_round.md`
2. Beauftrage einen frischen Subagent in der durch `Measurement-Qualität` bestimmten Stufe.
3. Warte auf Abschluss, prüfe Existenz der Output-Datei.

**2.5b — Cumulative-Measurement:**

1. Erzeuge `sparring/<NAME>/context/round_NN_measurement_cumulative_prompt.md` aus `templates/measurement_context.md.tpl`. Platzhalter:
   - `{MEASUREMENT_TYPE}` = `cumulative`
   - `{MEASUREMENT_TYPE_LABEL}` = `Cumulative`
   - `{ROUND}` = `NN`
   - `{INPUT_FILES}` = `sparring/<NAME>/rounds/round_01/measurement_baseline.md` (=feste Referenz, Pre-Scores) UND `sparring/<NAME>/rounds/round_NN/step_3_synthesis.md` (=aktueller Stand) UND `sparring/<NAME>/artifact.md`. Bei `NN >= 2` zusätzlich `sparring/<NAME>/rounds/round_{NN-1}/measurement_cumulative.md` für die Diminishing-Returns-Einschätzung.
   - `{PRE_LABEL}` = `Original-Baseline (rounds/round_01/measurement_baseline.md)`
   - `{POST_LABEL}` = `Synthese der Runde NN (rounds/round_NN/step_3_synthesis)`
   - `{OUTPUT_FILE}` = `sparring/<NAME>/rounds/round_NN/measurement_cumulative.md`
2. Beauftrage einen frischen Subagent in der durch `Measurement-Qualität` bestimmten Stufe.
3. Warte auf Abschluss, prüfe Existenz der Output-Datei.

Nach beiden erfolgreichen Aufrufen geht es weiter mit Schritt 3 (State-Update). Wenn einer der beiden Subagents fehlschlägt oder einen Inkonsistenz-Hinweis liefert: melde dem User, **schreibe state.md noch nicht** und starte keinen Wait-Loop. Kein stiller Fallback.

Hinweis: Diese Mess-Subagents fallen unter Orchestrierung der Hauptsession, nicht unter Step-Arbeit — das Spawnen ist erlaubt. Die Evaluator-Subagents selbst dürfen aber inhaltlich keine programmatische Messung durchführen (das ist in ihrem Kontext via `measurement_context.md.tpl` ausgeschlossen).

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
  - **Falls `Measurement: on`**: Kopiere zusätzlich `rounds/round_NN/measurement_cumulative.md` nach `sparring/<NAME>/MEASUREMENT.md`. Diese Datei dient als finaler Mess-Report. Das Format des Cumulative-Outputs deckt die gleichen Felder ab wie `templates/MEASUREMENT.md.tpl` — keine zusätzliche Aggregations-Logik nötig, da der Verlauf bereits in `state.md` und in den einzelnen `measurement_round.md`-Dateien dokumentiert ist.

### Schritt 4: Wait-Loop starten

Wie im INIT-Modus Schritt 7. Falls dieser Agent zum ersten Mal ins Sparring einsteigt: kein Hinweis an den User mehr nötig, der erste Hinweis kam vom Initiator.

Auch hier gilt Silent Wait Mode: Nach Start von `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"` bleibt der Agent stumm, bis der Prozess mit WAKE, DONE oder TIMEOUT endet.

## RESIZE-Modus (Sparring verlängern oder verkürzen)

Ändert die Gesamtrundenzahl eines bestehenden Sparrings — entweder hoch (Erweiterung) oder runter (Verkürzung). Funktioniert für **abgeschlossene** Sparrings (Erweiterung; häufigster Fall: nach manueller Sichtung des Finalartefakts mehr Schärfung gewünscht) und für **laufende** Sparrings (Plan wird nachträglich angepasst). Verkürzung ist nur für laufende Sparrings sinnvoll.

### Schritt 1: Sparring, Richtung und Zielrundenzahl parsen

- Parse aus der Trigger-Phrase den Sparring-Slug, die Richtung (Erweiterung oder Verkürzung) und die Zielrundenzahl `T`.
- Erweiterung kann als Delta (*"um 3 Runden"*) oder absolut (*"auf 8 Runden"*) ausgedrückt sein; berechne `T` entsprechend (`T = N + X` bzw. `T = X`).
- Verkürzung analog: *"auf 5 Runden"* → `T = 5`; *"um 2 Runden kürzen"* → `T = N - 2`; *"nach Runde 5 beenden"* → `T = 5`.
- Wenn der Slug fehlt und nur ein Sparring im Projekt existiert: dieses nehmen. Bei mehreren: User fragen.
- Wenn `T` nicht eindeutig aus der Phrase ableitbar ist: User fragen.
- Setze `<NAME>` auf den erkannten Slug.

### Schritt 2: State lesen, Plausibilität prüfen, Identität klären

- Lies `sparring/<NAME>/state.md`. Halte fest: aktueller `TOTAL_ROUNDS` = `N`, aktuelle Runde = `R`, aktueller `Status`.
- Allgemein:
  - Wenn `T > 10`: stoppe, melde *"Maximum sind 10 Runden gesamt; aktuell `N`"*.
  - Wenn `T < 1`: stoppe, ungültig.
  - Wenn `T == N`: stoppe, keine Änderung.
- Erweiterung (`T > N`): erlaubt für jeden Status.
- Verkürzung (`T < N`):
  - Bei `Status: completed`: stoppe, melde *"Ein abgeschlossenes Sparring kann nicht verkürzt werden — es ist bereits fertig. Wenn du die alte Fassung willst, nimm `FINAL_ARTIFACT.md` oder einen früheren Rundenordner."*
  - Bei `Status: waiting_for_output`: `T` muss `>= R` sein. Wenn `T < R`: stoppe, melde *"Aktuell läuft Runde `R`. Verkürzung auf `T` Runden ist nicht möglich; minimum ist `R`."*
- Identifiziere dich aus state.md: bist du der **Initiator** (Agent A) oder der **zweite Agent** (Agent B)? Wenn dein eigener Name eindeutig einem der beiden entspricht: nimm den. Bei Mehrdeutigkeit: User fragen.

### Schritt 3: state.md aktualisieren

- Setze `Aktuelle Runde:`-Zeile auf den neuen `T`-Wert. Bei Reaktivierung (vorher `completed`): auch die Runden-Nummer auf `N+1` setzen.
- Passe die Rotationsplan-Tabelle an: zeige Zeilen `1..T`. Bei Erweiterung Zeilen ergänzen (aus dem 10-Runden-Muster); bei Verkürzung Zeilen `T+1..N` entfernen.
- Bei Erweiterung mit vorherigem Status `completed`:
  - `Status:` → `waiting_for_output`
  - `Aktueller Schritt:` → `1 (These)`
  - `Rolle in diesem Schritt:` → `These`
  - `Dran:` → derjenige Agent, der laut Rotationsplan in Runde `N+1` die These macht
  - `Nächster Schritt nach dir:` → entsprechend setzen
- Bei Erweiterung oder Verkürzung mit Status `waiting_for_output`: keine weiteren Feldänderungen — nur `Aktuelle Runde:`-Zeile und Rotationstabelle.
- Verlauf-Eintrag anhängen: *"Sparring von `N` auf `T` Runden angepasst"* (Erweiterung) bzw. *"Sparring von `N` auf `T` Runden verkürzt"* (Verkürzung).

### Schritt 4: Neue Runde anlegen (nur bei reaktiviertem `completed`)

- Lege `sparring/<NAME>/rounds/round_{N+1}/` an.
- Bei `Artifact-Typ: file`: Kopiere `rounds/round_N/step_3_synthesis.md` → `rounds/round_{N+1}/artifact.md`.
- Bei `Artifact-Typ: directory`: Kopiere `rounds/round_N/step_3_synthesis/` → `rounds/round_{N+1}/artifact/`.
- Archiviere das alte Finalartefakt, damit es als Snapshot erhalten bleibt:
  - Datei: `mv sparring/<NAME>/FINAL_ARTIFACT.md sparring/<NAME>/FINAL_ARTIFACT_after_round_N.md`
  - Verzeichnis: `mv sparring/<NAME>/FINAL_ARTIFACT sparring/<NAME>/FINAL_ARTIFACT_after_round_N`
- Bei `Measurement: on`: Archiviere zusätzlich den alten Mess-Report analog: `mv sparring/<NAME>/MEASUREMENT.md sparring/<NAME>/MEASUREMENT_after_round_N.md`. Die `measurement_baseline.md` aus `rounds/round_01/` bleibt **unverändert** — sie ist die Original-Referenz und gilt auch für die ergänzten Runden. Folge-Cumulative-Messungen referenzieren weiterhin diese Baseline.

### Schritt 5: Wenn du dran bist, deinen Schritt erledigen (nur nach Reaktivierung)

- Wenn `Dran:` du bist: erledige These der Runde `N+1` analog zu JOIN-Modus Schritt 2, inkl. Beachtung von `Step-Ausführung` (Subagent oder Inline) und Projektkontext-Dateien.
- Wenn `Dran:` der andere ist: keine Step-Arbeit jetzt.

### Schritt 6: Handover-Prompt + Wait-Loop

- **Nach Reaktivierung** (vorher `completed`, jetzt erweitert): Emit den Handover-Prompt-Block für den anderen Agenten (gleicher Format wie INIT Schritt 7) — er muss seine Session wieder starten und ins fortgesetzte Sparring einsteigen. Danach `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"`.
- **Bei Resize eines laufenden Sparrings** (vorher `waiting_for_output`): kein neuer Wait-Loop. Bestätige dem User in einem Satz, dass der Plan jetzt `T` Runden umfasst — der bereits laufende Loop polled weiter und sieht das neue Total automatisch beim nächsten Rundenwechsel. Wenn der User dich getriggert hat, während du eigentlich im Wait-Loop sein solltest: zurück in den Wait-Loop. Bei Verkürzung: weise den User außerdem darauf hin, dass das Sparring nach der gerade laufenden oder der nächsten Synthese abschließt (sobald die aktuelle Runde die neue Gesamtzahl `T` erreicht).

## Pre-Check-Modus (lohnt sich ein Sparring überhaupt?)

Beantwortet vor einem möglichen Sparring die Frage: **Lohnt sich das hier?** Und wenn ja, **wie tief?** Der Pre-Check ist gedacht für zwei Situationen:

- **Pipeline-Modus** — automatisierter Aufruf in einer Prozesskette (z. B. "spar diesen Entwurf, wenn es sich lohnt"). Liefert nur eine `.md`-Datei, kein Scaffolding. Der aufrufende Prozess liest die Datei und entscheidet selbst.
- **Manueller Quick-Check** — User will wissen, ob es sich lohnt, bevor er INIT auslöst.

Der Pre-Check läuft **inline in der Hauptsession** — kein Subagent, kein Wait-Loop. Ein einziger Pass: Artefakt lesen, drei Dimensionen scoren, Empfehlung schreiben.

### Schritt 1: Artefaktpfad bestimmen

- Wenn die Trigger-Phrase einen konkreten Pfad enthält: nimm den. Verifiziere, dass die Datei oder das Verzeichnis existiert.
- Wenn nicht: Scanne das Projektverzeichnis (gleiche Logik wie INIT-Frage 1), schlage einen Pfad vor und frag einmal zurück. Im Pipeline-Modus (wo der Pfad immer in der Trigger-Phrase steht) entfällt das.
- Bei nicht existierender oder mehrdeutiger Eingabe: stoppe und frag den User.

### Schritt 2: Slug ableiten

- Leite den Slug aus dem Artefakt-Basename ab (gleiche Normalisierung wie INIT-Frage 2: nur Kleinbuchstaben, Ziffern, Bindestriche; Leerzeichen/Unterstriche zu `-`; sonstige Sonderzeichen entfernt).
- Bei `<NAME>`-Kollision unter `sparring/` siehe Schritt 3.

### Schritt 3: State-Konflikt prüfen

- Falls `sparring/<NAME>/state.md` existiert: stoppe und frage den User. Das könnte ein laufendes oder abgeschlossenes Sparring sein; der Pre-Check soll keine bestehenden Sparrings überschreiben oder verwirren.
- Falls die Trigger-Phrase explizit auf einen anderen, freien Slug deutet (z. B. *"pre-check für draft.md als draft-v2"*): nimm diesen.

### Schritt 4: Precheck-Existiert-Handling

- Falls `sparring/<NAME>/precheck.md` bereits existiert: melde dem User in einem Satz, dass die alte Version überschrieben wird, und mach weiter.

### Schritt 5: Sparring-Ordner anlegen

- Lege `sparring/<NAME>/` an, falls noch nicht vorhanden. Lege **kein** weiteres Scaffolding an (kein `state.md`, kein `CHALLENGE.md`, keine `rounds/`). Nur das Verzeichnis und später die `precheck.md` darin.

### Schritt 6: Erkannten Sparring-Typ ableiten

- Untersuche kurz das Artefakt (Format, Dateinamen, Inhalt) und leite einen der vier Typen ab: `Text`, `Campaign`, `Skill`, `Code` (gleiche Logik wie INIT Schritt 2 / Frage 6, ohne User-Rückfrage). Der Sparring-Typ fließt nur in die `precheck.md` als Information ein — die Rubric selbst ist typ-unabhängig.

### Schritt 7: Inline Pre-Check ausführen

- Lies `templates/precheck_rubric.md` vollständig.
- Lies `templates/precheck_context.md.tpl` als Strukturvorlage und ersetze gedanklich die Platzhalter (`{SPARRING_NAME}`, `{SPARRING_PATH}`, `{RESOLVED_SPARRING_TYPE}`, `{ARTIFACT_TYPE}`, `{RUBRIC_PATH}`, `{INPUT_FILES}`, `{OUTPUT_FILE}`) — diese Datei ist Vorlage für deine eigene inline-Arbeit, nicht für einen Subagenten. Sie definiert die Grenzen und das Output-Format verbindlich.
- Lies bei `Artifact-Typ: file` die Artefaktdatei direkt; bei `Artifact-Typ: directory` die wesentlichen Dateien des Verzeichnisses (gleiche Ausschlüsse wie in INIT Schritt 2).
- Falls eine `sparring/<NAME>/artifact.md` mit `Projektkontext`-Sektion existiert (kann im Pre-Check-Modus nicht der Fall sein, da kein Scaffolding läuft, aber im Turbo-Modus möglich): lies die referenzierten Pfade. Sonst: scanne kurz das Projektverzeichnis nach offensichtlichen Briefing-/Redaktionsplan-/Style-Guide-Dateien (Suchmuster wie in INIT-Frage 3) — qualitative Einordnung der Zielklarheit.
- Bewerte jede der drei Dimensionen isoliert (0, 1 oder 2 — keine halben Schritte).
- Wende die zwei Vetos an: bei `Headroom == 0` ODER `Zielklarheit == 0` → Score = **0**.
- Schätze die Größenklasse qualitativ ein (Klein/Mittel/Groß — kein `wc`, kein Zählen).
- Berechne `min(Roh-Empfehlung aus Score, Größen-Cap)` = finale Empfehlung.
- Schreibe das Ergebnis nach `sparring/<NAME>/precheck.md` im Format aus `templates/precheck_context.md.tpl` ("Output-Format"-Sektion).

### Schritt 8: Resümee an den User, Ende

- Gib in 2–3 Zeilen aus: Score, Veto-Status, finale Rundenempfehlung, Pfad zur `precheck.md`. Beispiel:

  > *"Pre-Check für `<NAME>`: Score 4/6, Größenklasse Mittel → **5 Runden empfohlen**. Details in `sparring/<NAME>/precheck.md`."*

- Bei `0 Runden / nicht empfohlen` zusätzlich der Hinweis, welches Veto griff (oder dass der Score zu niedrig war), z. B.:

  > *"Pre-Check für `<NAME>`: Headroom-Veto greift (Artefakt bereits ausgereift) → **Sparring nicht empfohlen**. Details in `sparring/<NAME>/precheck.md`."*

- **Kein Scaffolding, kein Wait-Loop, kein Handover-Prompt.** Der Modus endet hier. Der User (oder die aufrufende Pipeline) entscheidet, ob anschließend ein INIT/Turbo folgt.

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
- **Keine programmatische Messung oder Sektionsextraktion während der Step-Arbeit** — weder als Hauptsession (Inline-Modus) noch in Subagents. Konkret verboten: jede Form von Code-Ausführung zur Längen-Messung, Sektionsextraktion, Diff- oder Vergleichsberechnung gegen Vorrunden bzw. Referenzdateien. Das schließt ein: Shell-Pipes (`wc`, `awk`, `grep`, `sed`, `tr`, `cut`, `head`, `tail`), `python3 -c …`-One-Liner, Node-/Deno-Snippets, Inline-Skripte in beliebigen anderen Sprachen, sowie spontan angelegte Hilfsskripte. Das Verbot greift auch dann, wenn der Code "nur kurz mal" laufen soll. Solche Aufrufe brechen den Wait-Loop durch Permission-Prompts der Harness und liefern für die Rolle keinen Mehrwert: Längen-Constraints stehen in `CHALLENGE.md` und im Step-Kontext, alles andere ist Sprachgefühl. Native Read-/Write-Tools der Harness (z. B. `Read`, `Write`, `Edit`) bleiben erlaubt; nur programmatische Mess- und Analyseoperationen sind tabu. Orchestrierungs-Operationen der Hauptsession (Verzeichnis kopieren, neuen Rundenordner anlegen, Scaffolding-Datei schreiben, **Evaluator-Subagent für Measurement beauftragen**) zählen nicht als Step-Arbeit und sind weiter erlaubt. Auch der Evaluator-Subagent selbst arbeitet inhaltlich ohne programmatische Messung — diese Klausel ist in `measurement_context.md.tpl` festgeschrieben.
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
| `templates/measurement_context.md.tpl` | Vorlage für isolierten Evaluator-Subagent-Kontext (Baseline, Round-Delta, Cumulative) |
| `templates/precheck_rubric.md` | 3-Dim-Rubric für Pre-Check (Sparring-Fit), typ-unabhängig, inkl. Vetos und Größen-Cap |
| `templates/precheck_context.md.tpl` | Vorlage für inline Pre-Check der Hauptsession (Aufgabe, Grenzen, Output-Format) |
| `templates/measurement_rubric_text.md` | 5-Dim-Rubric für Sparring-Typ `Text` |
| `templates/measurement_rubric_campaign.md` | 5-Dim-Rubric für Sparring-Typ `Campaign` |
| `templates/measurement_rubric_skill.md` | 5-Dim-Rubric für Sparring-Typ `Skill` |
| `templates/measurement_rubric_code.md` | 5-Dim-Rubric für Sparring-Typ `Code` |
| `templates/MEASUREMENT.md.tpl` | Referenz-Layout für finalen Mess-Report (zur Orientierung, nicht zwingend kopiert) |

Platzhalter in den Templates haben die Form `{NAME}` und werden beim Scaffolding ersetzt.
