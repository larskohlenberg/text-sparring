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
2. Lies sparring/CHALLENGE.md für die Regeln.
3. Falls "Dran: {OTHER_NAME}" → erledige meinen ausstehenden
   Schritt strikt nach Rolle, schreibe die Output-Datei,
   aktualisiere state.md (Dran-Feld, Verlauf, ggf. neue Runde
   anlegen, falls ich gerade Synthese erledigt habe und Runde < 10).
4. Starte danach den Wait-Loop:
   bash sparring/watch_loop.sh "{OTHER_NAME}"
5. Reagiere auf Exit-Codes:
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
   state.md) und nichts sonst. Keine Meta-Kommentare im Output.
   Mein Name in der Challenge ist "{OTHER_NAME}".
   ```

2. Bei jedem Aufruf an den zweiten Agent kopierst du manuell rein:
   - aktuellen Inhalt von `sparring/state.md`
   - Inhalt von `sparring/CHALLENGE.md`
   - das relevante Input-File (artifact.md / step_1_thesis.md / step_2_antithesis.md)

3. Du nimmst den Output entgegen, speicherst ihn an der richtigen Stelle, aktualisierst state.md selbst und sagst dann **{MY_NAME}** in der anderen Session "weiter".

Diese Variante ist semi-automatisch — sie braucht dich als Datei-Botin/Boten zwischen den beiden Tools.

---

## Empfehlung

Bevorzuge **Variante A** mit Codex CLI oder einer zweiten Claude-Code-Instanz im selben Projektverzeichnis. Dann läuft die gesamte Challenge nach den beiden Initialaufrufen vollautonom.
