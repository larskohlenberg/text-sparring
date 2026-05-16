# Measurement (dialektische Qualitätsmessung)

Diese Datei beschreibt die optionale Qualitätsmessung pro Sparring. Wird nur gelesen, wenn `Measurement: on` in `state.md` steht.

## Worum es geht

Pro Sparring eine **Baseline-Bewertung** des Originalartefakts plus pro Runde zwei zusätzliche Evaluator-Subagent-Aufrufe (**Round-Delta** und **Cumulative**). 5-dimensionale Rubric, Werte 1–5, plus ein qualitativer Begleittext. Bei 5 Runden = 11 zusätzliche Evaluator-Calls.

Bei `Measurement: off` (Default) wird dieser ganze Pfad übersprungen — der Skill funktioniert komplett ohne Measurement.

## Baseline (nach Scaffolding, vor Schritt 1 der Runde 1)

Lasse einen neutralen Evaluator-Subagent eine einmalige Eingangs-Bewertung des Originalartefakts erstellen, **bevor** die These der Runde 1 läuft:

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

Wenn der Evaluator-Subagent stattdessen einen Inkonsistenz-Hinweis liefert (z. B. fehlende Inputs): melde das dem User, starte Schritt 1 noch nicht und keinen Wait-Loop. Kein stiller Fallback.

## Nach Synthese (Round-Delta + Cumulative)

Wenn der gerade erledigte Step die Synthese (Round-Step 3) war, führt die Hauptsession **vor** dem State-Update zwei zusätzliche Evaluator-Subagent-Aufrufe aus. Beide nutzen `templates/measurement_context.md.tpl` und die Rubric, die zum `Erkannter Sparring-Typ` passt (siehe Baseline-Sektion oben für die Rubric-Auswahl).

### Round-Delta-Measurement

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

### Cumulative-Measurement

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

Nach beiden erfolgreichen Aufrufen geht es weiter mit dem State-Update. Wenn einer der beiden Subagents fehlschlägt oder einen Inkonsistenz-Hinweis liefert: melde dem User, **schreibe state.md noch nicht** und starte keinen Wait-Loop. Kein stiller Fallback.

Hinweis: Diese Mess-Subagents fallen unter Orchestrierung der Hauptsession, nicht unter Step-Arbeit — das Spawnen ist erlaubt. Die Evaluator-Subagents selbst dürfen aber inhaltlich keine programmatische Messung durchführen (das ist in ihrem Kontext via `measurement_context.md.tpl` ausgeschlossen).

## Am Ende des Sparrings

Wenn der Synthese-Schritt der letzten Runde erledigt ist und `Measurement: on` gilt: Kopiere zusätzlich `rounds/round_NN/measurement_cumulative.md` nach `sparring/<NAME>/MEASUREMENT.md`. Diese Datei dient als finaler Mess-Report. Das Format des Cumulative-Outputs deckt die gleichen Felder ab wie `templates/MEASUREMENT.md.tpl` — keine zusätzliche Aggregations-Logik nötig, da der Verlauf bereits in `state.md` und in den einzelnen `measurement_round.md`-Dateien dokumentiert ist.
