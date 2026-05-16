# Turbo-Modus

Wenn die Trigger-Phrase des Users Worte wie **"Turbo"**, **"Schnellstart"**, **"ohne Fragen"**, **"auto"** oder **"quick"** im INIT-Kontext enthält (z. B. *"Starte ein Text-Sparring im Turbo-Modus über draft.md"*), überspringe das Interview komplett:

0. **Pre-Check ausführen** (inline, vor allem Weiteren): Führe Pre-Check-Modus Schritte 1, 2, **3**, 6, 7 aus (Artefakt parsen, Slug ableiten, **State-Konflikt-Check**, Sparring-Typ ableiten, `precheck.md` schreiben). State-Konflikt-Check (Schritt 3) bleibt auch im Turbo-Modus verbindlich — ein versehentlicher Turbo-Start in einem Projekt mit laufendem Sparring muss stoppen, nicht still kollidieren. Übersprungen wird nur Schritt 4 (Precheck-Existiert-Handling), weil Turbo eine ggf. existierende `precheck.md` beim Re-Run bewusst überschreibt. Lies die finale Empfehlung aus der erzeugten `precheck.md` und merke sie als `precheck_rounds`.
1. Sieh dir das Projektverzeichnis an (wie im Interview beschrieben).
2. Generiere konkrete Vorschläge für alle Interview-Punkte aus Projektkontext und Praxis-Defaults (gleiche Logik wie sonst, nur ohne den User zu fragen). **Measurement (Frage 10) ist im Turbo-Modus per Default `Off`**; nur wenn die Trigger-Phrase explizit "mit Messung", "with measurement", "mit Qualitätsmessung" o.ä. enthält, setze `On` und übernimm für alle übrigen Measurement-Felder die Defaults aus Frage 10. **Frage 7 (Anzahl Runden):** Übernimm `precheck_rounds` als Default, außer der User hat in der Trigger-Phrase explizit eine andere Zahl genannt (dann gewinnt die User-Zahl, die `precheck.md` bleibt aber als Nachvollziehbarkeit liegen).
3. Wenn die Trigger-Phrase einen konkreten Artefaktpfad enthält, nimm den; sonst leite ihn aus dem Projektkontext ab.
4. **Bei `precheck_rounds == 0`** (Sparring nicht empfohlen) UND keine User-Zahl in der Trigger-Phrase: Gib dem User die Empfehlung in 2–3 Zeilen (Score + Veto-Begründung + Pfad zur `precheck.md`) und frage einmal nach: *"Trotzdem starten? Wenn ja, mit wievielen Runden? (Empfehlung im Skipping-Fall: 3, oder Abbruch)"*. Bei Abbruch: stoppe, kein Scaffolding. Bei Bestätigung mit Rundenzahl: weiter mit dieser Zahl statt `precheck_rounds`.
5. Fasse die gewählte Konfiguration in 4–6 Zeilen zusammen und sage dem User in einem Satz, dass du jetzt loslegst.
6. Lege direkt das Scaffolding an, führe (falls `Measurement: on`) Baseline-Measurement aus (siehe Sibling-Skill `text-sparring-measurement`), und erledige Schritt 1 (These) — ohne weitere Rückfrage.
7. Gib am Ende den Handover-Prompt für den zweiten Agenten aus (siehe Haupt-SKILL.md INIT Schritt 7) und starte den Wait-Loop.

**Ausnahme:** Wenn du für einen einzelnen Punkt keinen vertretbaren Default ableiten kannst (z. B. mehrere gleichwertige Artefakt-Kandidaten und keiner in der Trigger-Phrase, oder der Name des zweiten Tools ist nicht erkennbar), frag **nur diese eine Frage** zurück und mach dann mit dem Rest direkt weiter. Kein vollständiges Interview.

Im Zweifel zugunsten der Geschwindigkeit entscheiden — der User kann das Sparring jederzeit abbrechen und neu starten.
