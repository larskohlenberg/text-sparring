# Text-Sparring — Regelwerk

**Initiator (Agent A):** {AGENT_A}
**Zweiter Agent (Agent B):** {AGENT_B}
**Gesamtrunden:** 10
**Polling-Intervall:** 30 Sekunden
**Max. Wartezeit pro Loop:** 30 Minuten

---

## Zweck

Zwei Agenten verbessern einen Text iterativ in 10 Runden. Jede Runde besteht aus drei Schritten — **These**, **Antithese**, **Synthese**. Die Synthese einer Runde wird zum Ausgangsartefakt der nächsten Runde. Nach Runde 10 endet die Challenge automatisch; das Ergebnis liegt in `FINAL_ARTIFACT.md`.

Es geht **nicht um einen Gewinner**. Es geht um akkumulierte Qualität durch Widerspruch und Integration.

---

## Rollen-Definitionen

Diese Definitionen gelten verbindlich für jeden Schritt — unabhängig davon, welcher Agent gerade die Rolle übernimmt. Wenn du als Agent eine dieser Rollen hast, befolge sie strikt.

### These (Schritt 1)

Du bist Autor der Runde. Deine Aufgabe:

- Lies `artifact.md` als Ausgangspunkt.
- Produziere die **bestmögliche Version** dieses Textes auf Basis dessen, was du jetzt weißt.
- Falls dies Runde 1 ist: das ist der erste Vorschlag. Verbessere den Ausgangstext substanziell, aber bleibe in seinem Thema und Geist.
- Falls dies Runde 2+ ist: `artifact.md` ist die Synthese der Vorrunde — baue darauf auf, nimm sie als Ausgangsbasis, aber verbessere mutig.

Schreibe das Ergebnis nach `step_1_thesis.md` in deinem aktuellen Rundenordner. Kein Kommentar, kein Meta-Text — nur der Text selbst.

### Antithese (Schritt 2)

Du bist jetzt **radikaler Zweifler**, nicht Autor.

Deine einzige Aufgabe: Finde die **drei fundamentalsten Annahmen** in `step_1_thesis.md` und stelle jede davon in Frage. Nicht den Text verbessern. Die Grundlagen erschüttern.

Formuliere für jede Annahme:

1. **Was wird hier als selbstverständlich angenommen?** (1–2 Sätze)
2. **Was wäre, wenn das Gegenteil wahr wäre?** (1–2 Sätze)
3. **Welche andere Struktur, welcher andere Ton, welche andere Schlussfolgerung würde dann entstehen?** (1–3 Sätze)

Optional am Ende: zwei bis drei kürzere, kleinere Beobachtungen ("Nebenkritik") — Stellen, an denen der Text nicht radikal falsch, aber unscharf, klischeehaft oder vermeidbar konventionell ist.

Schreibe das Ergebnis nach `step_2_antithesis.md`. Format:

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

### Synthese (Schritt 3)

Du hast jetzt `step_1_thesis.md` (These) und `step_2_antithesis.md` (Antithese).

Deine Aufgabe ist **nicht Kompromiss**, sondern **Integration**:

- Was aus der Kritik ist wahr — auch wenn es wehtut?
- Was bleibt trotzdem stehen, weil es trägt?
- Welche neue Form entsteht, wenn beide Wahrheiten gleichzeitig gelten?

Schreibe eine **neue Version des Textes**, die beides trägt. Kein "einerseits / andererseits". Eine Version, in der die Spannung produktiv aufgelöst ist.

Schreibe das Ergebnis nach `step_3_synthesis.md`. Wieder: nur der Text, kein Meta.

**Wichtig**: Diese Datei wird automatisch zum `artifact.md` der nächsten Runde. Schreibe also einen vollständigen, lauffähigen Text — nicht ein Diff oder eine Sammlung von Notizen.

---

## Rotationsplan (Vollrotation)

Jede Rolle wird über 10 Runden gleich oft von beiden Agenten besetzt (5×5).

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
sparring/rounds/round_NN/
├── artifact.md             ← Ausgangstext dieser Runde
├── step_1_thesis.md        ← These (von Agent gemäß Plan)
├── step_2_antithesis.md    ← Antithese
└── step_3_synthesis.md     ← Synthese — wird zum artifact.md der Folgerunde
```

Nach Runde 10 wird `step_3_synthesis.md` zusätzlich nach `sparring/FINAL_ARTIFACT.md` kopiert.

---

## Exit-Bedingungen

- Nach Schritt 3 der Runde 10: Challenge beendet, `state.md` zeigt `completed`.
- Während des Wait-Loops: Falls 30 Min Timeout → der wartende Agent fragt den User nach.
- Manueller Abbruch: User kann jederzeit einer Session sagen "stoppen", dann beendet der Agent den Loop und schreibt nichts mehr.

---

## Verhaltensregeln für beide Agenten

1. **state.md ist die einzige Wahrheit.** Vor jeder Aktion lesen — kein Vertrauen ins eigene Gedächtnis.
2. **Genau ein Schritt pro Aufwachen.** Nach Erledigung zurück in den Wait-Loop.
3. **Keine Meta-Kommentare in den Output-Dateien.** Reine Inhalts-Outputs.
4. **Bei Inkonsistenz**: Stop, frag den User. Nicht raten.
5. **Rollentreue**: Wenn du als Antithese-Agent versucht bist, "konstruktiv zu sein" — widerstehe. Die Rolle braucht die Schärfe.
