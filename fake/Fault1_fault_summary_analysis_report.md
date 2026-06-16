# Fault summary report: Fault1

## Automatic interpretation

The dominant fault signature is at **Terminal 3**, based mainly on the largest high-pass-filtered current derivative and current transient.

- Largest raw current peak: Terminal 3, value = 481.8
- Largest HPF current: Terminal 3, value = 301.4
- Largest d/dt of HPF current: Terminal 3, value = 4.6349e+07
- Largest DC voltage collapse: Terminal 4, value = 23.86

## Terminal DC-voltage and current ranking

|   Terminal |   Vdc_final |   Vdc_min |   Vdc_collapse_pct |   I_abs_peak_max |   HPF_current_maxabs |   dHPF_current_maxabs |   Pole_current_asymmetry_pct |
|-----------:|------------:|----------:|-------------------:|-----------------:|---------------------:|----------------------:|-----------------------------:|
|          1 |     1943.54 |   1931.05 |             3.4475 |          409.682 |            0.0870641 |         755.355       |                  0.00040363  |
|          2 |     1943.54 |   1931.05 |             3.4475 |          409.682 |            0.0870643 |         755.355       |                  0.00040363  |
|          3 |     1428.69 |   1428.68 |            21.8444 |          481.763 |          301.425     |           4.63494e+07 |                  0.800536    |
|          4 |     1328.6  |   1328.6  |            23.8626 |          167.191 |            0.170735  |        1641.01        |                  3.64171e-05 |

## Source-side symmetry check: Terminal 1 vs Terminal 2

- final DC voltage: T1=1944, T2=1944, difference=0%
- raw current peak: T1=409.7, T2=409.7, difference=1.9564e-12%
- HPF current: T1=0.08706, T2=0.08706, difference=1.6841e-04%
- d/dt HPF current: T1=755.4, T2=755.4, difference=2.2700e-05%

## Pole symmetry check

- Terminal 1: pole-current asymmetry = 4.0363e-04% → excellent
- Terminal 2: pole-current asymmetry = 4.0363e-04% → excellent
- Terminal 3: pole-current asymmetry = 0.8005% → excellent
- Terminal 4: pole-current asymmetry = 3.6417e-05% → excellent

## Frequency content of current signals

| Signal   |   HPF_MaxAbs |   D_HPF_MaxAbs |   PeakFreq1_Hz |    PeakAmp1 |   PeakFreq2_Hz |    PeakAmp2 |   PeakFreq3_Hz |    PeakAmp3 |
|:---------|-------------:|---------------:|---------------:|------------:|---------------:|------------:|---------------:|------------:|
| I_1+     |    0.0635563 |  662.2         |        599.88  | 0.0198944   |        739.852 | 0.00754267  |        899.82  | 0.00424916  |
| I_1-     |    0.0870641 |  755.355       |        599.88  | 0.0198918   |        739.852 | 0.0074899   |        899.82  | 0.00440037  |
| I_2+     |    0.0635563 |  662.201       |        599.88  | 0.0198944   |        739.852 | 0.00754266  |        899.82  | 0.00424915  |
| I_2-     |    0.0870643 |  755.355       |        599.88  | 0.0198918   |        739.852 | 0.00748991  |        899.82  | 0.00440036  |
| I_3+     |  301.387     |    4.63492e+07 |        579.884 | 0.0499604   |        739.852 | 0.0159514   |        659.868 | 0.0126623   |
| I_3-     |  301.425     |    4.63494e+07 |        579.884 | 0.0499677   |        739.852 | 0.0167517   |        659.868 | 0.0123586   |
| I_4+     |    0.1706    | 1641.01        |        639.872 | 0.000376298 |        919.816 | 0.000342869 |        559.888 | 0.000269912 |
| I_4-     |    0.170735  | 1640.4         |        639.872 | 0.000386179 |        919.816 | 0.000335868 |        559.888 | 0.000269547 |

## Report wording you can reuse

For Fault1, the strongest transient response occurs at Terminal 3. The largest high-frequency current and largest derivative of the high-pass-filtered current are both associated with this terminal, indicating that it is electrically closest to the faulted section. Terminals with lower HPF and derivative magnitudes are affected through the mesh but are not the dominant local discharge path.

The raw voltage minima describe which parts of the DC grid collapse after the fault, while the HPF current and derivative metrics identify the sharp capacitive-discharge signature. For a symmetric pole-to-pole fault, positive- and negative-pole current magnitudes should be similar with opposite sign, so low pole-current asymmetry supports a correctly wired symmetric-monopole model.
