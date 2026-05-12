# Text-Sparring Step Context

## Aufgabe

Erledige genau Runde {ROUND}, Schritt {STEP}: {ROLE}.

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
