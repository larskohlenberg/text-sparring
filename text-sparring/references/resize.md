# RESIZE-Modus (Sparring verlängern oder verkürzen)

Ändert die Gesamtrundenzahl eines bestehenden Sparrings — entweder hoch (Erweiterung) oder runter (Verkürzung). Funktioniert für **abgeschlossene** Sparrings (Erweiterung; häufigster Fall: nach manueller Sichtung des Finalartefakts mehr Schärfung gewünscht) und für **laufende** Sparrings (Plan wird nachträglich angepasst). Verkürzung ist nur für laufende Sparrings sinnvoll.

## Schritt 1: Sparring, Richtung und Zielrundenzahl parsen

- Parse aus der Trigger-Phrase den Sparring-Slug, die Richtung (Erweiterung oder Verkürzung) und die Zielrundenzahl `T`.
- Erweiterung kann als Delta (*"um 3 Runden"*) oder absolut (*"auf 8 Runden"*) ausgedrückt sein; berechne `T` entsprechend (`T = N + X` bzw. `T = X`).
- Verkürzung analog: *"auf 5 Runden"* → `T = 5`; *"um 2 Runden kürzen"* → `T = N - 2`; *"nach Runde 5 beenden"* → `T = 5`.
- Wenn der Slug fehlt und nur ein Sparring im Projekt existiert: dieses nehmen. Bei mehreren: User fragen.
- Wenn `T` nicht eindeutig aus der Phrase ableitbar ist: User fragen.
- Setze `<NAME>` auf den erkannten Slug.

## Schritt 2: State lesen, Plausibilität prüfen, Identität klären

- Lies `sparring/<NAME>/state.md`. Halte fest: aktueller `TOTAL_ROUNDS` = `N`, aktuelle Runde = `R`, aktueller `Status`.
- Allgemein:
  - Wenn `T > 10`: stoppe, melde *"Maximum sind 10 Runden gesamt; aktuell `N`"*.
  - Wenn `T < 1`: stoppe, ungültig.
  - Wenn `T == N`: stoppe, keine Änderung.
- Erweiterung (`T > N`): erlaubt für jeden Status.
- Verkürzung (`T < N`):
  - Bei `Status: completed`: stoppe, melde *"Ein abgeschlossenes Sparring kann nicht verkürzt werden — es ist bereits fertig. Wenn du die alte Fassung willst, nimm `FINAL_ARTIFACT.md` oder einen früheren Rundenordner."*
  - Bei `Status: waiting_for_output`: `T` muss `>= R` sein. Wenn `T < R`: stoppe, melde *"Aktuell läuft Runde `R`. Verkürzung auf `T` Runden ist nicht möglich; minimum ist `R`."*
- Identifiziere dich aus state.md: bist du der **Initiator** (Agent A) oder der **zweite Agent** (Agent B)? Wenn dein eigener Name eindeutig einem der beiden entspricht: nimm den. Bei Mehrdeutigkeit: User fragen.

## Schritt 3: state.md aktualisieren

- Setze `Aktuelle Runde:`-Zeile auf den neuen `T`-Wert. Bei Reaktivierung (vorher `completed`): auch die Runden-Nummer auf `N+1` setzen.
- Passe die Rotationsplan-Tabelle an: zeige Zeilen `1..T`. Bei Erweiterung Zeilen ergänzen (aus dem 10-Runden-Muster); bei Verkürzung Zeilen `T+1..N` entfernen.
- Bei Erweiterung mit vorherigem Status `completed`:
  - `Status:` → `waiting_for_output`
  - `Aktueller Schritt:` → `1 (These)`
  - `Rolle in diesem Schritt:` → `These`
  - `Dran:` → derjenige Agent, der laut Rotationsplan in Runde `N+1` die These macht
  - `Nächster Schritt nach dir:` → entsprechend setzen
- Bei Erweiterung oder Verkürzung mit Status `waiting_for_output`: keine weiteren Feldänderungen — nur `Aktuelle Runde:`-Zeile und Rotationstabelle.
- Verlauf-Eintrag anhängen: *"Sparring von `N` auf `T` Runden angepasst"* (Erweiterung) bzw. *"Sparring von `N` auf `T` Runden verkürzt"* (Verkürzung).

## Schritt 4: Neue Runde anlegen (nur bei reaktiviertem `completed`)

- Lege `sparring/<NAME>/rounds/round_{N+1}/` an.
- Bei `Artifact-Typ: file`: Kopiere `rounds/round_N/step_3_synthesis.md` → `rounds/round_{N+1}/artifact.md`.
- Bei `Artifact-Typ: directory`: Kopiere `rounds/round_N/step_3_synthesis/` → `rounds/round_{N+1}/artifact/`.
- Archiviere das alte Finalartefakt, damit es als Snapshot erhalten bleibt:
  - Datei: `mv sparring/<NAME>/FINAL_ARTIFACT.md sparring/<NAME>/FINAL_ARTIFACT_after_round_N.md`
  - Verzeichnis: `mv sparring/<NAME>/FINAL_ARTIFACT sparring/<NAME>/FINAL_ARTIFACT_after_round_N`
- Bei `Measurement: on`: Archiviere zusätzlich den alten Mess-Report analog: `mv sparring/<NAME>/MEASUREMENT.md sparring/<NAME>/MEASUREMENT_after_round_N.md`. Die `measurement_baseline.md` aus `rounds/round_01/` bleibt **unverändert** — sie ist die Original-Referenz und gilt auch für die ergänzten Runden. Folge-Cumulative-Messungen referenzieren weiterhin diese Baseline.

## Schritt 5: Wenn du dran bist, deinen Schritt erledigen (nur nach Reaktivierung)

- Wenn `Dran:` du bist: erledige These der Runde `N+1` analog zu JOIN-Modus Schritt 2, inkl. Beachtung von `Step-Ausführung` (Subagent oder Inline) und Projektkontext-Dateien.
- Wenn `Dran:` der andere ist: keine Step-Arbeit jetzt.

## Schritt 6: Handover-Prompt + Wait-Loop

- **Nach Reaktivierung** (vorher `completed`, jetzt erweitert): Emit den Handover-Prompt-Block für den anderen Agenten (gleiches Format wie INIT Schritt 7) — er muss seine Session wieder starten und ins fortgesetzte Sparring einsteigen. Danach `bash sparring/<NAME>/watch_loop.sh "{MY_NAME}"`.
- **Bei Resize eines laufenden Sparrings** (vorher `waiting_for_output`): kein neuer Wait-Loop. Bestätige dem User in einem Satz, dass der Plan jetzt `T` Runden umfasst — der bereits laufende Loop polled weiter und sieht das neue Total automatisch beim nächsten Rundenwechsel. Wenn der User dich getriggert hat, während du eigentlich im Wait-Loop sein solltest: zurück in den Wait-Loop. Bei Verkürzung: weise den User außerdem darauf hin, dass das Sparring nach der gerade laufenden oder der nächsten Synthese abschließt (sobald die aktuelle Runde die neue Gesamtzahl `T` erreicht).
