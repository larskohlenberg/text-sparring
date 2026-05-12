<!-- =============================================================
     DIALECTICAL CHALLENGE — Auto-Anweisung bei Sessionstart
     ============================================================= -->

## Dialektische Challenge läuft in diesem Projekt

In diesem Projektverzeichnis existiert ein `sparring/`-Verzeichnis. Es enthält einen laufenden dialektischen Verbesserungs-Loop mit zwei Agenten:

- **Mein Name in dieser Challenge:** `{MY_NAME}`
- **Anderer Agent:** `{OTHER_NAME}`

### Was ich bei Sessionstart tun soll

Falls die Challenge noch läuft (also `sparring/state.md` **nicht** den Status `completed` zeigt):

1. Lies sofort `sparring/state.md` und `sparring/artifact.md`.
2. Falls `Dran: {MY_NAME}` → erledige den ausstehenden Schritt nach den Regeln in `sparring/CHALLENGE.md`. Wenn `Step-Ausführung: subagent` gilt, erzeuge zuerst einen Step-Kontext in `sparring/context/` und delegiere nur die Step-Arbeit an einen Subagent. Lies den passenden Übergabeimpuls (`*_handoff.md`), falls vorhanden, schreibe Hauptoutput und neue Handoff-Datei, aktualisiere `state.md` (Dran, Verlauf, ggf. neue Runde anlegen), starte dann den Wait-Loop.
3. Falls `Dran: {OTHER_NAME}` → starte direkt den Wait-Loop. Keine Rückfrage.
4. Wait-Loop-Aufruf: `bash sparring/watch_loop.sh "{MY_NAME}"`

### Reaktion auf Exit des Wait-Loops

- Exit 0 (WAKE): Ich bin wieder dran — Schritt erledigen, state aktualisieren, Loop erneut starten.
- Exit 1 (DONE): Challenge fertig — User informieren, `sparring/FINAL_ARTIFACT.md` erwähnen.
- Exit 2 (TIMEOUT): User fragen, ob weiter gewartet werden soll.

### Was ich nicht tun soll

- Nicht den Inhalt der Output-Dateien diskutieren oder bewerten — nur produzieren gemäß Rolle.
- Nicht in einer Aktivierung mehrere Schritte erledigen — pro Aufwachen genau einer.
- Nicht state.md aus dem Gedächtnis manipulieren — immer vorher lesen.
- Nur das in `sparring/artifact.md` definierte Artefakt fortschreiben; Projektkontext darf helfen, ist aber nicht Output-Fläche.
- Hauptoutput und Übergabeimpuls trennen: Textfassung/Kritik/Synthese in die Step-Datei, Prüfimpulse in `*_handoff.md`.
- Subagents schreiben nur Step-Outputs. `state.md`, neue Runden und Wait-Loop bleiben Aufgabe der Hauptsession.

Volldetails: `sparring/CHALLENGE.md`.

<!-- ============================================================= -->
