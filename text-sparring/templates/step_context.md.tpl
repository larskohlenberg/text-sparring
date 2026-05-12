# Text-Sparring Step Context

## Aufgabe

Erledige genau Runde {ROUND}, Schritt {STEP}: {ROLE}.

## Sparring Artifact

Siehe `sparring/artifact.md`.

**Artifact-Typ:** {ARTIFACT_TYPE}
**Sparring-Typ:** {RESOLVED_SPARRING_TYPE}
**Aktuelle Arbeitsfassung:** {CURRENT_ARTIFACT_PATH}
**Subagent-Qualität:** {SUBAGENT_QUALITY}

## Rolle

Arbeite strikt nach der Rollen-Definition für **{ROLE}** in `sparring/CHALLENGE.md`.

## Input-Dateien

{INPUT_FILES}

## Output-Dateien

{OUTPUT_FILES}

## Grenzen

- Schreibe nur die genannten Output-Dateien.
- Aktualisiere nicht `sparring/state.md`.
- Lege keine neue Runde an.
- Starte keinen Wait-Loop.
- Halte Hauptoutput und Übergabeimpuls getrennt.
- Wenn notwendige Input-Dateien fehlen oder widersprüchlich sind, schreibe keine Outputs und melde die Inkonsistenz an die Hauptsession.
