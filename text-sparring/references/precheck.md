# Pre-Check-Modus (lohnt sich ein Sparring überhaupt?)

Beantwortet vor einem möglichen Sparring die Frage: **Lohnt sich das hier?** Und wenn ja, **wie tief?** Der Pre-Check ist gedacht für zwei Situationen:

- **Pipeline-Modus** — automatisierter Aufruf in einer Prozesskette (z. B. "spar diesen Entwurf, wenn es sich lohnt"). Liefert nur eine `.md`-Datei, kein Scaffolding. Der aufrufende Prozess liest die Datei und entscheidet selbst.
- **Manueller Quick-Check** — User will wissen, ob es sich lohnt, bevor er INIT auslöst.

Der Pre-Check läuft **inline in der Hauptsession** — kein Subagent, kein Wait-Loop. Ein einziger Pass: Artefakt lesen, drei Dimensionen scoren, Empfehlung schreiben.

## Schritt 1: Artefaktpfad bestimmen

- Wenn die Trigger-Phrase einen konkreten Pfad enthält: nimm den. Verifiziere, dass die Datei oder das Verzeichnis existiert.
- Wenn nicht: Scanne das Projektverzeichnis (gleiche Logik wie INIT-Frage 1), schlage einen Pfad vor und frag einmal zurück. Im Pipeline-Modus (wo der Pfad immer in der Trigger-Phrase steht) entfällt das.
- Bei nicht existierender oder mehrdeutiger Eingabe: stoppe und frag den User.

## Schritt 2: Slug ableiten

- Leite den Slug aus dem Artefakt-Basename ab (gleiche Normalisierung wie INIT-Frage 2: nur Kleinbuchstaben, Ziffern, Bindestriche; Leerzeichen/Unterstriche zu `-`; sonstige Sonderzeichen entfernt).
- Bei `<NAME>`-Kollision unter `sparring/` siehe Schritt 3.

## Schritt 3: State-Konflikt prüfen

- Falls `sparring/<NAME>/state.md` existiert: stoppe und frage den User. Das könnte ein laufendes oder abgeschlossenes Sparring sein; der Pre-Check soll keine bestehenden Sparrings überschreiben oder verwirren.
- Falls die Trigger-Phrase explizit auf einen anderen, freien Slug deutet (z. B. *"pre-check für draft.md als draft-v2"*): nimm diesen.

## Schritt 4: Precheck-Existiert-Handling

- Falls `sparring/<NAME>/precheck.md` bereits existiert: melde dem User in einem Satz, dass die alte Version überschrieben wird, und mach weiter.

## Schritt 5: Sparring-Ordner anlegen

- Lege `sparring/<NAME>/` an, falls noch nicht vorhanden. Lege **kein** weiteres Scaffolding an (kein `state.md`, kein `CHALLENGE.md`, keine `rounds/`). Nur das Verzeichnis und später die `precheck.md` darin.

## Schritt 6: Erkannten Sparring-Typ ableiten

- Untersuche kurz das Artefakt (Format, Dateinamen, Inhalt) und leite einen der vier Typen ab: `Text`, `Campaign`, `Skill`, `Code` (gleiche Logik wie INIT Schritt 2 / Frage 6, ohne User-Rückfrage). Der Sparring-Typ fließt nur in die `precheck.md` als Information ein — die Rubric selbst ist typ-unabhängig.

## Schritt 7: Inline Pre-Check ausführen

- Lies `templates/precheck_rubric.md` vollständig.
- Lies `templates/precheck_context.md.tpl` als Strukturvorlage und ersetze gedanklich die Platzhalter (`{SPARRING_NAME}`, `{SPARRING_PATH}`, `{RESOLVED_SPARRING_TYPE}`, `{ARTIFACT_TYPE}`, `{RUBRIC_PATH}`, `{INPUT_FILES}`, `{OUTPUT_FILE}`) — diese Datei ist Vorlage für deine eigene inline-Arbeit, nicht für einen Subagenten. Sie definiert die Grenzen und das Output-Format verbindlich.
- Lies bei `Artifact-Typ: file` die Artefaktdatei direkt; bei `Artifact-Typ: directory` die wesentlichen Dateien des Verzeichnisses (gleiche Ausschlüsse wie in INIT Schritt 2).
- Falls eine `sparring/<NAME>/artifact.md` mit `Projektkontext`-Sektion existiert (kann im Pre-Check-Modus nicht der Fall sein, da kein Scaffolding läuft, aber im Turbo-Modus möglich): lies die referenzierten Pfade. Sonst: scanne kurz das Projektverzeichnis nach offensichtlichen Briefing-/Redaktionsplan-/Style-Guide-Dateien (Suchmuster wie in INIT-Frage 3) — qualitative Einordnung der Zielklarheit.
- Bewerte jede der drei Dimensionen isoliert (0, 1 oder 2 — keine halben Schritte).
- Wende die zwei Vetos an: bei `Headroom == 0` ODER `Zielklarheit == 0` → Score = **0**.
- Schätze die Größenklasse qualitativ ein (Klein/Mittel/Groß — kein `wc`, kein Zählen).
- Berechne `min(Roh-Empfehlung aus Score, Größen-Cap)` = finale Empfehlung.
- Schreibe das Ergebnis nach `sparring/<NAME>/precheck.md` im Format aus `templates/precheck_context.md.tpl` ("Output-Format"-Sektion).

## Schritt 8: Resümee an den User, Ende

- Gib in 2–3 Zeilen aus: Score, Veto-Status, finale Rundenempfehlung, Pfad zur `precheck.md`. Beispiel:

  > *"Pre-Check für `<NAME>`: Score 4/6, Größenklasse Mittel → **5 Runden empfohlen**. Details in `sparring/<NAME>/precheck.md`."*

- Bei `0 Runden / nicht empfohlen` zusätzlich der Hinweis, welches Veto griff (oder dass der Score zu niedrig war), z. B.:

  > *"Pre-Check für `<NAME>`: Headroom-Veto greift (Artefakt bereits ausgereift) → **Sparring nicht empfohlen**. Details in `sparring/<NAME>/precheck.md`."*

- **Kein Scaffolding, kein Wait-Loop, kein Handover-Prompt.** Der Modus endet hier. Der User (oder die aufrufende Pipeline) entscheidet, ob anschließend ein INIT/Turbo folgt.
