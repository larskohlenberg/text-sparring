# Rubric: Skill

Rubric für `Erkannter Sparring-Typ: Skill` (Skills, Agent-Workflows, Prompt-/Template-Systeme, `.skill`-Bundles).

Fünf Dimensionen, jeweils 1 (schwach) – 5 (exzellent), halbe Schritte erlaubt.

---

## 1. Trigger-Präzision

*Beschreibt die `description` im Frontmatter klar, wann der Skill ausgelöst werden soll? Konkrete Phrasen, eindeutige Abgrenzung zu anderen Skills?*

- **1**: Vage Beschreibung, keine Trigger-Phrasen, hohes False-Positive-/False-Negative-Risiko.
- **3**: Trigger-Phrasen vorhanden, aber teils zu generisch oder mit Overlap zu anderen Skills.
- **5**: Trigger-Phrasen sind konkret, abgrenzend, decken DE/EN-Varianten ab; Skill aktiviert sich verlässlich genau dann, wenn er soll.

## 2. Schritt-Determinismus

*Sind die Anweisungen so präzise, dass zwei verschiedene Agents das Gleiche tun würden? Keine Mehrdeutigkeiten, keine "je nachdem"-Stellen ohne Regel.*

- **1**: Viele Interpretationsspielräume, Verhalten variiert stark zwischen Sessions.
- **3**: Hauptpfad klar, aber Edge-Cases und Sub-Entscheidungen unterspezifiziert.
- **5**: Jede Verzweigung explizit geregelt; deterministischer Ablauf von Trigger bis Output.

## 3. Edge-Case-Abdeckung

*Werden Fehlerzustände, leere Inputs, Konflikte, Race-Conditions, fehlende Dateien explizit behandelt?*

- **1**: Nur der Happy-Path beschrieben.
- **3**: Wichtige Fehlerfälle adressiert (z. B. Datei existiert nicht), aber kein systematisches Gate-Konzept.
- **5**: Klare Gates/Vorprüfungen vor jedem Schreibakt; Inkonsistenzen werden gemeldet statt geraten; Mehrdeutigkeiten lösen Rückfragen aus.

## 4. Lesbarkeit für den Agent

*Ist der Skill so geschrieben, dass ein Agent ihn beim ersten Lesen versteht und ausführen kann? Klare Sektionen, sinnvolle Reihenfolge, keine versteckten Annahmen?*

- **1**: Wand aus Text, keine erkennbare Struktur, wichtige Regeln versteckt.
- **3**: Lesbar mit Aufwand; Hauptablauf erschließt sich, Feinheiten erfordern mehrfaches Springen.
- **5**: Klare Sektionen mit erwarteter Reihenfolge (Trigger → Modi → Schritte → Verhaltensregeln); jedes Detail an seinem erwartbaren Ort.

## 5. Constraint-Treue

*Hält der Skill die in `artifact.md` und Projektkontext definierten Meta-Constraints ein (z. B. Plattform-Konventionen, Tool-Beschränkungen, Format-Vorgaben für Skill-Bundles)?*

- **1**: Verstößt gegen Plattform-Konventionen (z. B. Skill-Frontmatter-Format) oder bricht erklärte Tool-Beschränkungen.
- **3**: Hält Plattform-Konventionen ein, mit erkennbaren Abweichungen.
- **5**: Vollständig konform; nutzt Plattform-Mechanismen produktiv (Frontmatter, Templates, Hooks etc.).

---

## Hinweise für den Evaluator

- Bei Skills mit **mehreren Modi** (z. B. INIT, JOIN, RESIZE): scort die Dimensionen für den Skill als Ganzes, mit Hinweis in der Begründung auf Modi mit besonderer Stärke/Schwäche.
- Determinismus-Bewertung: stell dir vor, du müsstest den Skill als kalter Agent ausführen — wo musst du raten?
- Lesbarkeit ist nicht "schön" sondern "scannbar" — können die Schritte beim Überfliegen aufgenommen werden?
