# Vier harte Gates vor jeder Schreibaktion

Vor jedem Output diese vier Prüfungen durchlaufen. Wenn ein Gate fehlschlägt: **nichts schreiben**, dem User melden, welche Datei oder welches Feld konkret nicht passt. Nicht raten, nicht reparieren.

1. **Role Gate** — Wirst du mit einer expliziten Kontextdatei `sparring/<NAME>/context/round_NN_step_M_prompt.md` aufgerufen, bist du **Step Worker**: erledige genau diesen einen Schritt, schreibe nur die im Kontext genannten Output-Pfade. Du liest oder änderst **nicht** `state.md`, legst keine neuen Runden an, kopierst keine Final-Artefakte, startest keinen Wait-Loop. Ohne Kontextdatei bist du **Hauptsession** und folgst INIT- oder JOIN-Modus.
2. **Input Gate** — Alle für deine Rolle erwarteten Inputs existieren und sind lesbar (`artifact.md`, die Runden-Dateien aus den Vorgängerschritten, ggf. Vorrunden-Handoff). Bei Directory-Inputs muss das Verzeichnis tatsächlich Dateien enthalten.
3. **Output Gate** — Die für deine Rolle erwarteten Output-Pfade enthalten noch keinen Inhalt. Findest du dort schon Text oder Dateien, ist der Schritt vermutlich bereits gelaufen — melde das dem User, statt zu überschreiben.
4. **Execution Mode Gate** — Steht in `state.md` `Ausführungsmodus: Subagent`, kannst du aber keinen Subagenten starten: **sofort stoppen und den User fragen**. Kein stiller Fallback auf Inline. Kein Weitermachen mit dem nächsten Schritt.
