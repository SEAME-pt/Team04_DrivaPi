# Trustable Compliance Report



## Item status guide ## { .subsection }

Each item in a Trustable Graph is scored with a number between 0 and 1.
The score represents aggregated organizational confidence in a given Statement, with larger numbers corresponding to higher confidence.
Scores in the report are indicated by both a numerical score and the colormap below:
<div class="br" style="height: 26px; width: 80%;background: linear-gradient(to right in hsl, hsl(0.0, 100%, 65%) 0%, hsl(120.0, 100%, 30%) 100%);">
<span style="float:right;">1.00&nbsp</span>
<span style="float:left;">&nbsp0.00</span>
</div>


The status of an item and its links also affect the score.

Unreviewed items are indicated by a cross in the status column.
The score of unreviewed items is always set to zero.


Suspect links are indicated by a cross in the status column.
The contribution to the score of a parent item by a suspiciously linked child is always zero, regardless of the child's own score.
## Compliance for LLTC

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [LLTC-001](LLTC.md#lltc-001) {class="tsf-score" style="background-color:hsl(0.0, 100%, 65%)"} | Test case to verify SWD-001 conversion from raw CAN data to km/h. | 0.00 | ☑ Item Reviewed<br>☑ Children linked<br> |

## Compliance for SRD

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [SRD-001](SRD.md#srd-001) {class="tsf-score" style="background-color:hsl(0.0, 100%, 65%)"} | The system SHALL read vehicle speed data from the CAN bus at 10Hz. | 0.00 | ☑ Item Reviewed<br>☑ Children linked<br> |

## Compliance for SWD

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [SWD-001](SWD.md#swd-001) {class="tsf-score" style="background-color:hsl(0.0, 100%, 65%)"} | The software SHALL convert raw CAN speed data (0.1 km/h units) to integer km/h and update the display module within 50ms of receipt. | 0.00 | ☑ Item Reviewed<br>☑ Children linked<br> |

## Compliance for URD

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [URD-001](URD.md#urd-001) {class="tsf-score" style="background-color:hsl(0.0, 100%, 65%)"} | The system SHALL provide the user with real-time vehicle speed information displayed on the dashboard within 100ms of data receipt. | 0.00 | ☑ Item Reviewed<br>☑ Children linked<br> |


---

_Generated for: Software_

* _Repository root: /Users/melaniereis/Documents/GitHub/Team04_DrivaPi_
* _Commit SHA: 996d39b4cbe1351847bbc7baa571bfcc709ae151_
* _Commit date/time: 2025-10-21 20:47:57 UTC_
* _Commit tag: BASELINE-SWD-V1.0-56-g996d39b_
