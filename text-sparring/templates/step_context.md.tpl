# Text-Sparring Step Context

## Aufgabe

Erledige genau Runde {ROUND}, Schritt {STEP}: {ROLE}.

## Sparring

- **Sparring-Name:** {SPARRING_NAME}
- **Sparring-Pfad:** {SPARRING_PATH}

Siehe `{SPARRING_PATH}/artifact.md`.

**Artifact-Typ:** {ARTIFACT_TYPE}
**Sparring-Typ:** {RESOLVED_SPARRING_TYPE}
**Aktuelle Arbeitsfassung:** {CURRENT_ARTIFACT_PATH}
**Subagent-Qualität:** {SUBAGENT_QUALITY}

## Rolle

Arbeite strikt nach der Rollen-Definition für **{ROLE}** in `{SPARRING_PATH}/CHALLENGE.md`.

## Input-Dateien

{INPUT_FILES}

## Output-Dateien

{OUTPUT_FILES}

## Grenzen

- Schreibe nur die genannten Output-Dateien.
- Aktualisiere nicht `{SPARRING_PATH}/state.md`.
- Lege keine neue Runde an.
- Starte keinen Wait-Loop.
- Halte Hauptoutput und Übergabeimpuls getrennt.
- Wenn notwendige Input-Dateien fehlen oder widersprüchlich sind, schreibe keine Outputs und melde die Inkonsistenz an die Hauptsession.
- **Keine anderen Skills aktivieren.** Dieser Step läuft im Single-Skill-Modus der text-sparring-Skill. Aktiviere insbesondere nicht `brainstorming`, `test-driven-development`, `systematic-debugging`, `using-superpowers`, `writing-plans` oder andere Workflow-Skills, auch wenn ihre Beschreibungen passen könnten. Dein Job ist ausschließlich die Rolle aus `CHALLENGE.md`. Ausnahme nur, wenn die Hauptsession in diesem Step-Kontext einen anderen Skill explizit benennt.
