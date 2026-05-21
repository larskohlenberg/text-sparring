# Text-Sparring — Regelwerk

**Sparring-Name:** {SPARRING_NAME}
**Sparring-Pfad:** {SPARRING_PATH}
**Initiator (Agent A):** {AGENT_A}
**Zweiter Agent (Agent B):** {AGENT_B}
**Gesamtrunden:** {TOTAL_ROUNDS}
**Polling-Intervall:** 30 Sekunden
**Max. Wartezeit pro Loop:** 30 Minuten

---

## Sparring-Gegenstand

Der konkrete Gegenstand steht in `{SPARRING_PATH}/artifact.md` und zusätzlich in `{SPARRING_PATH}/state.md`.

- `Artifact-Typ: file` bedeutet: Die Arbeitsfassung ist eine einzelne Datei (`artifact.md`, `step_1_thesis.md`, `step_3_synthesis.md`).
- `Artifact-Typ: directory` bedeutet: Die Arbeitsfassung ist ein Verzeichnis (`artifact/`, `step_1_thesis/`, `step_3_synthesis/`).

Bei `Artifact-Typ: directory` erzeugen nur These und Synthese Verzeichnisse. Die Antithese bleibt immer `step_2_antithesis.md`, weil sie keine neue Artefaktfassung ist, sondern strukturierte Kritik.

---

## Rollen-Definitionen

Diese Definitionen gelten verbindlich für jeden Schritt — unabhängig davon, welcher Agent gerade die Rolle übernimmt. Wenn du als Agent eine dieser Rollen hast, befolge sie strikt.

**Vor jedem Schritt** lies die unter `Projektkontext` in `{SPARRING_PATH}/artifact.md` aufgeführten Dateien. Sie enthalten Constraints (Längen, Tonalität, Zielgruppe, Brand Voice, Format-Vorgaben), die zusätzlich zu den hier definierten Rollen-Regeln gelten. Wenn dort `(keine)` steht, ist kein Projektkontext aktiv.

### These (Schritt 1)

Du bist Autor der Runde. Deine Aufgabe:

- Lies `artifact.md` als Ausgangspunkt.
- Produziere die **bestmögliche Version** dieses Textes auf Basis dessen, was du jetzt weißt.
- Falls dies Runde 1 ist: das ist der erste Vorschlag. Verbessere den Ausgangstext substanziell, aber bleibe in seinem Thema und Geist.
- Falls dies Runde 2+ ist: `artifact.md` ist die Synthese der Vorrunde — baue darauf auf, lies zusätzlich `step_3_handoff.md` aus der Vorrunde, aber verbessere mutig.

Bei `Artifact-Typ: file`: Schreibe das Ergebnis nach `step_1_thesis.md` in deinem aktuellen Rundenordner. Kein Kommentar, kein Meta-Text — nur der Text selbst.

Bei `Artifact-Typ: directory`: Schreibe die neue Fassung als vollständiges Verzeichnis nach `step_1_thesis/`. Erhalte sinnvolle relative Pfade. Entferne Dateien nur, wenn es die Qualität des Artefakts klar verbessert.

Schreibe zusätzlich nach `step_1_handoff.md` einen kurzen Übergabeimpuls für die Antithese:

```markdown
## Übergabeimpuls
- Welche Annahme im Text sollte der nächste Agent besonders hart prüfen?
- Welche Stelle wirkt stark, könnte aber auf falschen Voraussetzungen beruhen?
- Welche Entscheidung in Ton, Struktur oder Pointe ist absichtlich riskant?
```

### Antithese (Schritt 2)

Du bist jetzt **radikaler Zweifler**, nicht Autor. Lies `step_1_handoff.md`, falls vorhanden, bevor du prüfst.

Deine einzige Aufgabe: Finde die **drei fundamentalsten Annahmen** in `step_1_thesis.md` und stelle jede davon in Frage. Nicht den Text verbessern. Die Grundlagen erschüttern.

Formuliere für jede Annahme:

1. **Was wird hier als selbstverständlich angenommen?** (1–2 Sätze)
2. **Was wäre, wenn das Gegenteil wahr wäre?** (1–2 Sätze)
3. **Welche andere Struktur, welcher andere Ton, welche andere Schlussfolgerung würde dann entstehen?** (1–3 Sätze)

Optional am Ende: zwei bis drei kürzere, kleinere Beobachtungen ("Nebenkritik") — Stellen, an denen der Text nicht radikal falsch, aber unscharf, klischeehaft oder vermeidbar konventionell ist.

Schreibe das Ergebnis immer nach `step_2_antithesis.md`. Format:

```markdown
## Annahme 1: <kurzer Titel>
**Selbstverständlich angenommen:** ...
**Wenn das Gegenteil wahr wäre:** ...
**Alternative Struktur:** ...

## Annahme 2: ...

## Annahme 3: ...

## Nebenkritik
- ...
- ...
```

Schreibe zusätzlich nach `step_2_handoff.md` einen kurzen Übergabeimpuls für die Synthese:

```markdown
## Übergabeimpuls
- Welche Kritik muss die Synthese unbedingt ernst nehmen?
- Welche These darf trotz Kritik nicht vorschnell geopfert werden?
- Wo liegt die produktive Spannung, aus der eine bessere Fassung entstehen kann?
```

### Synthese (Schritt 3)

Du hast jetzt `step_1_thesis.md` (These), `step_2_antithesis.md` (Antithese) und `step_2_handoff.md` (Übergabeimpuls der Antithese).

Deine Aufgabe ist **nicht Kompromiss**, sondern **Integration**:

- Was aus der Kritik ist wahr — auch wenn es wehtut?
- Was bleibt trotzdem stehen, weil es trägt?
- Welche neue Form entsteht, wenn beide Wahrheiten gleichzeitig gelten?

Schreibe eine **neue Version des Textes**, die beides trägt. Kein "einerseits / andererseits". Eine Version, in der die Spannung produktiv aufgelöst ist.

Bei `Artifact-Typ: file`: Schreibe das Ergebnis nach `step_3_synthesis.md`. Wieder: nur der Text, kein Meta.

Bei `Artifact-Typ: directory`: Schreibe die integrierte neue Fassung als vollständiges Verzeichnis nach `step_3_synthesis/`.

**Wichtig**: Dieser Output wird automatisch zum Artefakt der nächsten Runde. Schreibe also eine vollständige, lauffähige Fassung — nicht ein Diff oder eine Sammlung von Notizen.

Schreibe zusätzlich nach `step_3_handoff.md` einen kurzen Übergabeimpuls für die nächste Runde:

```markdown
## Übergabeimpuls
- Welche neu entstandene Annahme sollte die nächste Runde prüfen?
- Welche Stelle ist verbessert, aber noch nicht endgültig gelöst?
- Welche Richtung sollte die nächste These mutig weiterverfolgen?
```

---

## Übergabeimpulse

Jeder Schritt erzeugt neben seinem Hauptoutput eine separate `*_handoff.md`-Datei. Diese Datei gibt dem nächsten Agenten 1–3 konkrete Prüf- oder Schärfimpulse mit.

Der Übergabeimpuls ist **keine** Anweisung, die Rolle des nächsten Schritts zu verlassen. Er markiert nur Stellen, an denen der Text besonders Spannung, Risiko oder ungenutztes Potenzial enthält. Der nächste Agent liest den passenden Übergabeimpuls vor seinem Schritt und berücksichtigt ihn innerhalb seiner Rolle. Wenn ein Impuls der Rolle widerspricht, gilt die Rolle.

Regeln:

- Maximal 3 Bulletpoints.
- Keine Meta-Diskussion über den Prozess.
- Keine höflichen Arbeitsanweisungen.
- Nur konkrete Prüfimpulse am Text.

---

## Rotationsplan

| Runde | These | Antithese | Synthese |
|-------|-------|-----------|----------|
| 1     | {AGENT_A} | {AGENT_B} | {AGENT_A} |
| 2     | {AGENT_B} | {AGENT_A} | {AGENT_B} |
| 3     | {AGENT_A} | {AGENT_B} | {AGENT_B} |
| 4     | {AGENT_B} | {AGENT_A} | {AGENT_A} |
| 5     | {AGENT_A} | {AGENT_A} | {AGENT_B} |
| 6     | {AGENT_B} | {AGENT_B} | {AGENT_A} |
| 7     | {AGENT_A} | {AGENT_B} | {AGENT_A} |
| 8     | {AGENT_B} | {AGENT_A} | {AGENT_B} |
| 9     | {AGENT_A} | {AGENT_B} | {AGENT_B} |
| 10    | {AGENT_B} | {AGENT_A} | {AGENT_A} |

---

## Datei-Layout pro Runde

```
{SPARRING_PATH}/rounds/round_NN/
├── artifact.md|artifact/   ← Ausgangsartefakt dieser Runde
├── step_1_thesis.md|/      ← These (von Agent gemäß Plan)
├── step_1_handoff.md       ← Übergabeimpuls an die Antithese
├── step_2_antithesis.md    ← Antithese
├── step_2_handoff.md       ← Übergabeimpuls an die Synthese
├── step_3_synthesis.md|/   ← Synthese — wird zum Artefakt der Folgerunde
└── step_3_handoff.md       ← Übergabeimpuls an die nächste Runde
```

Nach der letzten Runde wird `step_3_synthesis.md` beziehungsweise `step_3_synthesis/` zusätzlich nach `{SPARRING_PATH}/FINAL_ARTIFACT.md` oder `{SPARRING_PATH}/FINAL_ARTIFACT/` kopiert.

---

## Verhaltensregeln

1. **Keine Meta-Kommentare in den Output-Dateien.** Reine Inhalts-Outputs.
2. **Übergabeimpulse getrennt halten.** Prüfimpulse gehören in `*_handoff.md`, nicht in die Hauptoutput-Dateien.
3. **Bei Inkonsistenz**: Stop, frag den User. Nicht raten.
4. **Rollentreue**: Wenn du als Antithese-Agent versucht bist, "konstruktiv zu sein" — widerstehe. Die Rolle braucht die Schärfe.
