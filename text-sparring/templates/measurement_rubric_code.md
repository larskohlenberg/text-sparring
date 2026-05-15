# Rubric: Code

Rubric für `Erkannter Sparring-Typ: Code` (Quellcode, Tests, Build-Dateien, technische Implementierungen).

Fünf Dimensionen, jeweils 1 (schwach) – 5 (exzellent), halbe Schritte erlaubt.

---

## 1. Korrektheit

*Erkennbare Logikfehler, falsche Bedingungen, Off-by-One, falsche API-Nutzung, falsche Datenstrukturen.*

- **1**: Offensichtliche Logikfehler, der Code würde in mehreren Fällen falsch laufen.
- **3**: Happy-Path korrekt, Randfälle teils falsch oder ungeprüft.
- **5**: Logik korrekt für alle erkennbaren Pfade; APIs werden gemäß ihrer Verträge genutzt.

Hinweis: Du führst den Code **nicht** aus (Programmatik-Verbot). Bewerte durch Lesen.

## 2. Testbarkeit

*Sind Verantwortlichkeiten so geschnitten, dass Tests sinnvoll geschrieben werden können? Keine versteckten Abhängigkeiten, klare Inputs/Outputs.*

- **1**: Verflochten, mit globalen Zuständen, I/O direkt im Geschäftscode, kaum testbar ohne Refactoring.
- **3**: Hauptteile testbar, mit erkennbaren Reibungspunkten (z. B. enge Kopplung an externe Services).
- **5**: Klare Trennung von Logik und I/O; Schnittstellen sind klein und ohne versteckten Zustand; Tests sind leicht zu formulieren.

## 3. Lesbarkeit & Konventions-Treue

*Naming, Struktur, Formatierung, gegen Projekt-Conventions im Kontext.*

- **1**: Inkonsistente Naming-Konventionen, lange Funktionen ohne Abschnittsgliederung, gegen Projekt-Conventions.
- **3**: Lesbar mit Aufwand; Konventionen meist eingehalten.
- **5**: Code liest sich wie Prosa; Naming ist präzise; Projekt-Conventions durchgängig respektiert.

## 4. Robustheit

*Edge-Cases, Fehlerbehandlung, Null/Empty/Race-Bedingungen, Eingabevalidierung an Systemgrenzen.*

- **1**: Bricht bei leichten Abweichungen vom Happy-Path; keine Fehlerbehandlung.
- **3**: Wichtige Fehlerfälle abgedeckt, mit erkennbaren Lücken (z. B. fehlende Validierung an einer Schnittstelle).
- **5**: Eingaben an Systemgrenzen validiert; interne Aufrufe vertrauen sich; Fehlerpfade führen zu klaren, nicht zu stillen Defaults.

## 5. Skopus-Treue

*Bleibt der Code im Scope der Aufgabe? Keine ungebetenen Refactorings, keine Abstraktionen für hypothetische Zukunft, keine Feature-Erweiterungen unter dem Vorwand der Bugfix-Aufgabe.*

- **1**: Massive Scope-Verbreiterung; unklar, was das Sparring eigentlich ändern wollte.
- **3**: Hauptfokus erkennbar, aber mit angehängten "Verbesserungen", die nicht angefragt waren.
- **5**: Scharf im Scope; keine ungebetenen Änderungen; jede Zeile dient der gestellten Aufgabe.

---

## Hinweise für den Evaluator

- Du führst **nichts** aus. Bewertung erfolgt durch Lesen. Wenn Korrektheit nur durch Ausführung beurteilbar wäre, scort vorsichtig (3.0) und vermerke in der Begründung "Korrektheit nur lesend abschätzbar".
- Bei mehrteiligen Code-Artefakten (mehrere Dateien): scort den Durchschnitt, mit Hinweis auf Ausreißer.
- Projekt-Conventions sind nur dann verbindlich, wenn sie im Projektkontext gelistet sind (z. B. `CONTRIBUTING.md`, Style-Guide). Sonst orientiere dich an erkennbaren Mustern im Original-Input.
