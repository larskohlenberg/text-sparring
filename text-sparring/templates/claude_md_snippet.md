<!-- =============================================================
     DIALECTICAL CHALLENGE — Auto-Anweisung bei Sessionstart
     Sparring: {SPARRING_NAME} ({SPARRING_PATH})
     ============================================================= -->

## Dialektische Challenge "{SPARRING_NAME}" läuft in diesem Projekt

In diesem Projektverzeichnis existiert das Sparring `{SPARRING_PATH}/`. Es enthält einen laufenden dialektischen Verbesserungs-Loop mit zwei Agenten:

- **Mein Name in dieser Challenge:** `{MY_NAME}`
- **Anderer Agent:** `{OTHER_NAME}`
- **Sparring-Pfad:** `{SPARRING_PATH}`

Falls weitere Sparring-Snippets in dieser CLAUDE.md stehen, gehören sie zu anderen aktiven Sparrings. Behandle jedes Snippet als eigenständig — orientiere dich am `Sparring-Pfad`.

### Was ich bei Sessionstart tun soll

Falls die Challenge noch läuft (also `{SPARRING_PATH}/state.md` **nicht** den Status `completed` zeigt):

1. Lies sofort `{SPARRING_PATH}/state.md` und `{SPARRING_PATH}/artifact.md`.
2. Falls `Dran: {MY_NAME}` → erledige den ausstehenden Schritt nach den Regeln in `{SPARRING_PATH}/CHALLENGE.md`. Wenn `Step-Ausführung: subagent` gilt, erzeuge zuerst einen Step-Kontext in `{SPARRING_PATH}/context/` und delegiere nur die Step-Arbeit an einen Subagent. Lies den passenden Übergabeimpuls (`*_handoff.md`), falls vorhanden, schreibe Hauptoutput und neue Handoff-Datei, aktualisiere `state.md` (Dran, Verlauf, ggf. neue Runde anlegen), starte dann den Wait-Loop.
3. Falls `Dran: {OTHER_NAME}` → starte direkt den Wait-Loop. Keine Rückfrage.
4. Wait-Loop-Aufruf: `bash {SPARRING_PATH}/watch_loop.sh "{MY_NAME}"`
5. Nach Start des Wait-Loops stumm bleiben, bis WAKE, DONE oder TIMEOUT erscheint.

### Reaktion auf Exit des Wait-Loops

- Exit 0 (WAKE): Ich bin wieder dran — Schritt erledigen, state aktualisieren, Loop erneut starten.
- Exit 1 (DONE): Challenge fertig — User informieren, `{SPARRING_PATH}/FINAL_ARTIFACT.md` (oder `/FINAL_ARTIFACT/`) erwähnen.
- Exit 2 (TIMEOUT): User fragen, ob weiter gewartet werden soll.

### Was ich nicht tun soll

- Nicht den Inhalt der Output-Dateien diskutieren oder bewerten — nur produzieren gemäß Rolle.
- Nicht in einer Aktivierung mehrere Schritte erledigen — pro Aufwachen genau einer.
- Nicht state.md aus dem Gedächtnis manipulieren — immer vorher lesen.
- Während der Wait-Loop läuft keine Zwischenberichte, Statusmeldungen, Spekulationen oder UI-Kommentare ausgeben.
- Nur das in `{SPARRING_PATH}/artifact.md` definierte Artefakt fortschreiben; Projektkontext darf helfen, ist aber nicht Output-Fläche.
- Hauptoutput und Übergabeimpuls trennen: Textfassung/Kritik/Synthese in die Step-Datei, Prüfimpulse in `*_handoff.md`.
- Subagents schreiben nur Step-Outputs. `state.md`, neue Runden und Wait-Loop bleiben Aufgabe der Hauptsession.
- **Single-Skill-Modus während des Sparrings:** Keine anderen Skills automatisch aktivieren — nicht `brainstorming`, `test-driven-development`, `systematic-debugging`, `using-superpowers`, `writing-plans` oder andere Workflow-Skills. Das Sparring orchestriert sich selbst. Ausnahme nur, wenn der User in seinem aktuellen Prompt explizit einen Skill benennt.

Volldetails: `{SPARRING_PATH}/CHALLENGE.md`.

<!-- ============================================================= -->
