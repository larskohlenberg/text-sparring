# Instructions für den zweiten Agent ({OTHER_NAME})

Dies ist der Anweisungstext, den du in **{OTHER_NAME}** einfügen musst, damit der zweite Agent in die Challenge einsteigen kann.

---

## Variante A: Codex CLI / lokaler Agent mit Datei-Zugriff

Wenn der zweite Agent direkten Zugriff auf das Projektverzeichnis hat (Codex CLI, Cowork, zweite Claude-Code-Instanz), kopiere folgenden Text als ersten Prompt nach dem Sessionstart:

```
Im aktuellen Projektverzeichnis ({PROJECT_PATH}) läuft eine
dialektische Challenge. Mein Name in der Challenge ist
"{OTHER_NAME}".

Bitte:
1. Lies sparring/state.md vollständig.
2. Lies sparring/artifact.md und sparring/CHALLENGE.md für Artefakt, Sparring-Typ und Regeln.
3. Falls "Dran:" den bekannten anderen Agenten zeigt → starte direkt
   den Wait-Loop mit meinem Namen. Keine Rückfrage.
4. Falls "Dran: {OTHER_NAME}" → erledige meinen ausstehenden
   Schritt strikt nach Rolle, lies den passenden Übergabeimpuls
   (`*_handoff.md`), falls er existiert, schreibe die Output-Datei
   und die neue Handoff-Datei,
   aktualisiere state.md (Dran-Feld, Verlauf, ggf. neue Runde
   anlegen, falls ich gerade Synthese erledigt habe und die aktuelle
   Runde kleiner als die Gesamtrundenzahl ist).
   Wenn state.md `Step-Ausführung: subagent` zeigt, erzeuge zuerst
   einen isolierten Step-Kontext unter `sparring/context/` und delegiere
   den Schritt an einen frischen Subagent/Worker, falls dein Tool das
   unterstützt. Der Subagent darf state.md nicht aktualisieren.
   Beachte `Subagent-Qualität`; wenn dein Tool keine Qualitätswahl
   erlaubt, verwende faktisch Inherit.
5. Starte danach den Wait-Loop:
   bash sparring/watch_loop.sh "{OTHER_NAME}"
6. Reagiere auf Exit-Codes:
   - 0 (WAKE) → nächsten Schritt erledigen, Loop erneut starten
   - 1 (DONE) → mich informieren, FINAL_ARTIFACT.md erwähnen
   - 2 (TIMEOUT) → mich fragen, ob weiter warten

Pro Aufwachen genau ein Schritt. state.md ist die einzige Wahrheit.
```

## Variante B: ChatGPT Web (ohne lokalen Datei-Zugriff)

Wenn der zweite Agent **kein** lokaler Datei-Zugriff hat (ChatGPT-Web ohne Code Interpreter / ohne MCP-File-Connector), funktioniert der Wait-Loop nicht.

In diesem Fall:

1. Lege als Custom Instructions / System Prompt im zweiten Agent folgendes ab:

   ```
   Du arbeitest an einer dialektischen Challenge im Wechsel mit
   einem anderen Agent ({MY_NAME}). Pro Anfrage von mir bekommst
   du den aktuellen Zustand als Text-Block, befolgst die Regeln
   aus CHALLENGE.md (die ich dir mitliefere), produzierst exakt
   einen Output (These / Antithese / Synthese je nach Rolle laut
   state.md) plus einen separaten Übergabeimpuls für den nächsten
   Agenten. Keine Meta-Kommentare im Hauptoutput.
   Beachte Artifact-Typ (`file` oder `directory`) und erkannten
   Sparring-Typ (`Text`, `Campaign`, `Skill` oder `Code`).
   Wenn der Zustand einen Subagent-Modus beschreibt, behandle ihn als
   Kontextisolations-Wunsch. Ohne lokalen Datei- und Subagent-Zugriff
   bleibst du im semi-manuellen Modus.
   Mein Name in der Challenge ist "{OTHER_NAME}".
   ```

2. Bei jedem Aufruf an den zweiten Agent kopierst du manuell rein:
   - aktuellen Inhalt von `sparring/state.md`
   - Inhalt von `sparring/artifact.md`
   - Inhalt von `sparring/CHALLENGE.md`
   - das relevante Input-File (artifact.md / step_1_thesis.md / step_2_antithesis.md)
   - den passenden Übergabeimpuls (`*_handoff.md`), falls vorhanden

3. Du nimmst Hauptoutput und Übergabeimpuls entgegen, speicherst sie an den richtigen Stellen, aktualisierst state.md selbst und sagst dann **{MY_NAME}** in der anderen Session "weiter".

Diese Variante ist semi-automatisch — sie braucht dich als Datei-Botin/Boten zwischen den beiden Tools.

---

## Empfehlung

Bevorzuge **Variante A** mit Codex CLI oder einer zweiten Claude-Code-Instanz im selben Projektverzeichnis. Dann läuft die gesamte Challenge nach den beiden Initialaufrufen vollautonom.
