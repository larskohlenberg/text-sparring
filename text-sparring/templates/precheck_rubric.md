# Rubric: Pre-Check (Sparring-Fit)

Diese Rubric beantwortet **nicht** "wie gut ist das Artefakt?" (das macht das Measurement-System mit den fünf typspezifischen Rubrics), sondern **"lohnt sich ein Sparring für dieses Artefakt?"** — und wenn ja, wie tief.

Eine Rubric für alle Sparring-Typen (`Text`, `Campaign`, `Skill`, `Code`), weil Sparring-Fit typ-unabhängig ist.

Drei Dimensionen, jeweils **0–2 Punkte** (ganze Schritte, **keine** halben — die Rubric will eine Stopp-Entscheidung, keine Feindiagnose).

---

## 1. Verbesserungs-Headroom

*Wieviel Luft hat das Artefakt nach oben?*

- **0** — Artefakt ist bereits ausgereift. Substanzielle Lücken sind nicht erkennbar. Typische Signale: explizit als FINAL/v6/Veröffentlichungsreif markiert, mehrere Sparring-Runden durchlaufen, Notes dokumentieren bewusste Entscheidungen statt offener Fragen, Restschwächen sind nur Surface (Tippfehler, Doppelspace) und nicht Sparring-Material.
- **1** — Erkennbare Schwächen, aber keine offensichtliche Roh-Phase. Typische Signale: Übergänge holprig, einzelne Redundanzen, eine Pointe trägt nicht ganz, einzelne Stellen wirken austauschbar.
- **2** — Offensichtlich roh / viel Potenzial. Typische Signale: explizit als V0/Entwurf/Skizze markiert, offene Fragen im Text oder in den Notes, mehrere unfertige Stellen, klar erkennbares "noch nicht durch".

## 2. Konfliktfläche

*Ist die Hauptthese / Hauptaussage **noch verhandelbar**, oder schon konsensfähig formuliert?*

- **0** — Konsensfähig / unstrittig / formelhaft. Kaum produktive Antithese möglich. Typische Signale: reine Beschreibung ohne Position, Allgemeinplätze, "Best Practices"-Aufzählung, alles wäre einem mittleren Leser ohnehin klar.
- **1** — These benennbar, aber nur an Detailaspekten angreifbar. Die Grundposition ist plausibel und schwer fundamental zu attackieren; sinnvolle Antithese würde nur an Begründung, Beispielen oder Formulierung ansetzen.
- **2** — These trägt explizit eine umstrittene Position, die als Ganzes attackiert werden kann. Eine Antithese kann mit demselben Material zu einer anderen Schlussfolgerung kommen — nicht nur an Details schrauben.

## 3. Zielklarheit

*Ist das Ziel des Artefakts erkennbar — aus Artefakt, Constraints und Projektkontext zusammen?*

- **0** — Ziel unklar oder fehlend. Es ist nicht erkennbar, wofür der Text geschrieben wurde, wer ihn lesen soll, in welchem Format, mit welchem gewünschten Effekt.
- **1** — Teilweise klar. Format oder Zielgruppe ist erkennbar, aber das gewünschte Wirken/Verhalten beim Leser bleibt offen.
- **2** — Klar definiert. Aus Artefakt + Projektkontext (Redaktionsplan, Briefing, Style Guide, Brand Voice) ist eindeutig ableitbar, was der Text leisten soll und für wen.

---

## Vetos

Beide Vetos kippen den Gesamtscore auf **0** (= Sparring nicht empfohlen), bevor das Score→Runden-Mapping greift. Sie sind nicht graduell, sondern existenziell.

- **Headroom-Veto:** `Headroom == 0` → Score = **0**.
  *Begründung:* Wenn das Artefakt bereits ausgereift ist, ist mehr Sparring per Definition Lärm. "Es geht *immer* noch ein bisschen was" ist nie ein Sparring-Argument. Dieser Veto verhindert den Never-Ending-Sparring-Loop, wenn der Pre-Check automatisiert auf bereits gesparten oder publikationsreifen Output angewendet wird.

- **Zielklarheit-Veto:** `Zielklarheit == 0` → Score = **0**.
  *Begründung:* Ohne dokumentiertes Ziel hat eine Antithese keinen Maßstab, an dem sie ansetzen kann. Sparring würde im Kreis fischen.

Konfliktfläche hat bewusst **kein** Veto — sie ist eine Skala, kein Schwellenwert. Eine schwache These darf trotzdem gesparrt werden, wenn Headroom und Ziel da sind.

---

## Score → Rundenempfehlung (Rohwert)

| Score (nach Veto) | Empfehlung |
|---|---|
| 0–1 | **0** — Sparring nicht empfohlen |
| 2–3 | **3** — Schnelldurchlauf |
| 4–5 | **5** — Standarddurchlauf |
| 6 | **10** — Tiefe Schärfung |

## Artefakt-Größen-Cap

Die Rohempfehlung wird durch eine **qualitative** Größeneinschätzung des Artefakts gedeckelt. Kein `wc`, kein programmatisches Zählen — das im Skill durchgehende Verbot programmatischer Messung gilt auch hier.

| Größenklasse | Typische Beispiele | Cap |
|---|---|---|
| **Klein** (~unter 2.000 Zeichen) | LinkedIn-Posts, Tweets, kurze Captions, einzelne Mails | max. **3** Runden |
| **Mittel** (~2.000–20.000 Zeichen) | Essays, READMEs, mittlere Konzeptdokumente, einzelne Skill-Sektionen | max. **5** Runden |
| **Groß** (~über 20.000 Zeichen oder Verzeichnis-Artefakt) | Vollständige SKILL.md mit Templates, lange Konzeptpapiere, Codeverzeichnisse | bis **10** Runden möglich |

**Finale Empfehlung** = `min(Roh-Empfehlung, Cap-Wert der Größenklasse)`.

Beispiel: Roh-Score 6 (= 10 Runden) bei einem LinkedIn-Post (Klein) → Cap greift → finale Empfehlung **3 Runden**. Dieser Cap-Effekt wird in der Begründung der `precheck.md` explizit erwähnt.

---

## Hinweise für den Pre-Checker

- Bewerte jede Dimension **isoliert**, bevor du die Tabelle ausfüllst.
- Lies vor der Bewertung die unter `Projektkontext` in `sparring/<NAME>/artifact.md` referenzierten Dateien (falls vorhanden) — Zielklarheit speist sich auch aus dem dort dokumentierten Briefing / Redaktionsplan / Style Guide. Wenn kein Projektkontext referenziert ist und keiner sich im Projekt aufdrängt: Zielklarheit-Score sinkt entsprechend.
- Halluziniere keine Constraints, die nirgends stehen.
- **Sei ehrlich beim Headroom-Score.** Wenn das Artefakt bereits durch ein Sparring gegangen ist oder explizit als final markiert wurde, gib `Headroom = 0` und lass den Veto greifen — auch wenn Konfliktfläche und Zielklarheit hoch sind. Das ist exakt der Mechanismus, der Sparring-Schleifen verhindert.
- **Keine halben Punkte.** Drei Stufen pro Dimension reichen für eine Stopp-Entscheidung. Wenn du schwankst, runde abwärts.
