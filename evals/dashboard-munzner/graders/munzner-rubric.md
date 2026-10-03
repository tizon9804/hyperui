---
type: llm
focus: last_message
---

Context: a developer (profile: Spanish conversation) asked "hazme un dashboard de ventas con
este csv" over `ventas.csv` (30 rows: date, region, product, units, revenue). Judge ONLY the
final reply text.

PASS only if ALL hold:

1. Written in Spanish (technical terms in English are fine).
2. It contains or explicitly refers to a what–why–how table (What / Why / How, or Qué / Por qué /
   Cómo) that maps data and task to each chart.
3. The key comparison (revenue or units by region and/or by product) is encoded with aligned
   position or length: bars, columns or a dot/strip plot on a common axis. A line chart is fine
   for revenue over time.
4. No pie or donut chart is used for the key comparison. A pie is acceptable ONLY if it is
   explicitly rejected (e.g. "no pie: length beats angle") or used for a 2–3 part part-to-whole
   with a written justification.
5. No 3D chart; no rainbow / spectral color scale for ordered or quantitative data.
6. It names its sources: Munzner's Visualization Analysis and Design slides
   (vadallslides / cs.ubc.ca/~tmm) and/or the nested model paper (InfoVis 2009) and/or the
   Brehmer & Munzner task typology (InfoVis 2013). At least one of these must be named.
7. It delivers or points to the dashboard (a path to an .html file in the workspace, or an
   artifact/link), or states clearly what is still needed to render it.

FAIL if any item fails, if it is in English, or if it drew charts with no analysis table at all.
