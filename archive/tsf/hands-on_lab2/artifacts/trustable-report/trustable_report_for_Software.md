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
| [LLTC-996](LLTC.md#lltc-996) {class="tsf-score" style="background-color:hsl(1.2, 100%, 64%)"} | Verifies that unit test coverage for the motor speed driver meets the defined project threshold of 80%. | 0.01 | ☑ Item Reviewed<br>☑ Children linked<br> |
| [LLTC-997](LLTC.md#lltc-997) {class="tsf-score" style="background-color:hsl(114.0, 100%, 31%)"} | Verifies SWD-998 implementation against static analysis rules. | 0.95 | ☑ Item Reviewed<br>☑ Children linked<br> |
| [LLTC-998](LLTC.md#lltc-998) {class="tsf-score" style="background-color:hsl(82.8, 100%, 40%)"} | Verifies SWD-998 implementation through unit tests for motor speed functionality. | 0.69 | ☑ Item Reviewed<br>☑ Children linked<br> |

## Compliance for SRD

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [SRD-998](SRD.md#srd-998) {class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"} | The motor speed sensing subsystem shall provide real-time RPM measurements using a GPIO-connected tachometer sensor to support operator monitoring and test validation. | 0.55 | ☑ Item Reviewed<br>☑ Children linked<br> |

## Compliance for SWD

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [SWD-998](SWD.md#swd-998) {class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"} | ## Software Design Requirement Statement | 0.55 | ☑ Item Reviewed<br>☑ Children linked<br> |

## Compliance for URD

| Item {style="width:10%"} | Summary {style="width:60%"} | Score {style="width:5%"} | Status {style="width:25%"} |
| ----- | ----- | ----- | ----- |
| [URD-998](URD.md#urd-998) {class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"} | Operators need to monitor motor speed during test operations to ensure tests run within acceptable performance ranges and to detect anomalies. | 0.55 | ☑ Item Reviewed<br>☑ Children linked<br> |


---

_Generated for: Software_

* _Repository root: /Users/melaniereis/Documents/GitHub/Team04_DrivaPi_
* _Commit SHA: e6c7163cd187de593108c279665b998229f2e00a_
* _Commit date/time: 2025-11-12 18:34:43 UTC_
* _Commit tag: BASELINE-SWD-V1.0-247-ge6c7163_
