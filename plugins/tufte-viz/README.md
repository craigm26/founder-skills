# tufte-viz — charts that respect the reader

Ideate and critique data visualizations using Edward Tufte's principles from *The Visual Display
of Quantitative Information*: data-ink ratio, chartjunk elimination, graphical integrity, lie
factor, small multiples, data density.

## Before you install

Use it **before** building any chart or dashboard, or to critique an existing one. It ships four
working single-file HTML demos as calibration examples — NASA GISS temperature, Kyoto sakura
flowering dates, and two sunspot treatments (the honest butterfly vs the pretty one) — plus
reference docs on analytical design.

## What it will ask you

Nothing structured — describe the data and the question the chart should answer.

## What it produces

A design critique or a concrete chart design (often as a self-contained HTML file) grounded in
named principles, with the trade-offs stated.

## Cost

Minimal — single-model design work.

## 60-second first run

```
/tufte-viz — "critique this dashboard screenshot" or "design a chart for 10 years of churn data"
```

Open `demos/sunspot-butterfly.html` next to `demos/sunspot-pretty.html` to calibrate what the
skill considers honest versus decorative.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Skills | Principles + demos loaded as session context on invocation | [Skills](https://code.claude.com/docs/en/skills) |
