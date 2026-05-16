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

## Projektkontext (Pflichtlektüre vor der Step-Arbeit)

Lies vor Beginn deines Schritts alle in `{SPARRING_PATH}/artifact.md` unter `Projektkontext` aufgeführten Dateien. Sie enthalten Constraints (Längen, Tonalität, Zielgruppe, Brand Voice, Format-Vorgaben), die zusätzlich zur Rolle aus `CHALLENGE.md` gelten und im Output respektiert werden müssen. Steht dort `(keine)`, überspringe diesen Schritt.

## Rolle

Arbeite strikt nach der Rollen-Definition für **{ROLE}** in `{SPARRING_PATH}/CHALLENGE.md`, unter Einhaltung der Projektkontext-Vorgaben.

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
- **Keine programmatische Messung oder Sektionsextraktion für Inhaltsarbeit.** Lies die im Kontext gelisteten Input-Dateien mit den nativen Read-Werkzeugen deines Tools (Read/View). Verboten ist jede Form von Code-Ausführung zur Längen-Messung, Sektionsausschnitt, Diff- oder Vergleichsberechnung — egal in welcher Sprache. Das schließt explizit ein: Shell-Pipes (`wc`, `awk`, `grep`, `sed`, `tr`, `cut`, `head`, `tail`), `python3 -c …`-One-Liner, Node-/Deno-Snippets, Inline-Skripte in anderen Sprachen sowie spontan angelegte Hilfsskripte. Auch nicht "nur kurz mal, um die Vorrunde abzugleichen". Solche Aufrufe triggern Sicherheitsabfragen der Harness, brechen den Wait-Loop des aufrufenden Agenten und liefern für die Rolle keinen Mehrwert: Längen-Constraints stehen — wenn relevant — in `CHALLENGE.md` oder im Step-Kontext, alles andere ist Sache deines Sprachgefühls. Schreib-Operationen (Write/Edit auf die Output-Dateien) sind davon nicht betroffen.
