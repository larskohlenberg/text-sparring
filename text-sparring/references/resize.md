# RESIZE-Modus (Sparring verlängern oder verkürzen)

Ändert die Gesamtrundenzahl eines bestehenden Sparrings. Erweiterung funktioniert für laufende und abgeschlossene Sparrings; Verkürzung nur für laufende.

## Vorgehen

1. **Parsen.** Sparring-Slug, Richtung und Zielrundenzahl `T` aus der Trigger-Phrase ableiten. Delta (`um 3 Runden`) und absolut (`auf 8 Runden`) beide unterstützt. Bei nur einem Sparring im Projekt: Slug optional. Wenn `T` oder Slug nicht eindeutig: User fragen.
2. **Plausibilität.** Lies `sparring/<NAME>/state.md`. Aktuelles `TOTAL_ROUNDS = N`, laufende Runde `R`. Stoppe bei: `T > 10`, `T < 1`, `T == N`, oder Verkürzung eines `completed`-Sparrings, oder Verkürzung auf `T < R`. Klare Fehlermeldung an den User.
3. **state.md anpassen.** `Aktuelle Runde:` auf `T`. Rotationsplan-Tabelle auf Zeilen `1..T` zuschneiden (bei Erweiterung aus dem 10-Runden-Muster ergänzen). Verlauf-Eintrag *"Sparring von N auf T Runden angepasst/verkürzt"* anhängen.
4. **Bei Reaktivierung eines `completed`-Sparrings:** zusätzlich `Status:` → `waiting_for_output`, `Aktueller Schritt:` → `1 (These)`, `Dran:` → laut Rotationsplan in Runde `N+1`, `Nächster Schritt nach dir:` → entsprechend. Lege `rounds/round_{N+1}/` an und kopiere die letzte Synthese als neues Runden-Input (`artifact.md` bzw. `artifact/`). Archiviere altes Finalartefakt (`mv FINAL_ARTIFACT.md FINAL_ARTIFACT_after_round_N.md` bzw. Verzeichnis-Variante). Bei `Measurement: on` analog `MEASUREMENT.md` archivieren; die `measurement_baseline.md` aus `rounds/round_01/` bleibt unverändert (Original-Referenz).
5. **Abschluss.**
   - Bei Reaktivierung: Handover-Prompt-Block für den anderen Agenten ausgeben (gleiches Format wie INIT Schritt 7), dann `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"`. Wenn du laut `Dran:` selbst die These der neuen Runde übernimmst, mach sie inline analog JOIN-Modus Schritt 2, dann erst den Handover/Loop.
   - Bei Resize eines laufenden Sparrings (vorher `waiting_for_output`): kein neuer Loop, kein Handover. Bestätige dem User in einem Satz, dass der Plan jetzt `T` Runden umfasst — der bereits laufende Loop sieht das neue Total beim nächsten Rundenwechsel automatisch. Bei Verkürzung: weise hin, dass das Sparring nach der gerade laufenden oder nächsten Synthese abschließt.
