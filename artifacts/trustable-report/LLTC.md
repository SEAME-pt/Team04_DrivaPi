

---

### LLTC-001 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(0.0, 100%, 65%)"}
Test case to verify SWD-001 conversion from raw CAN data to km/h.

**Test Procedure:**
- Setup:
  - Initialize conversion module
- Test Steps:
  1. Provide raw value 200 → Expected: Converts to 20 km/h
  2. Provide raw value 0 → Expected: Converts to 0 km/h
- Postconditions:
  - No errors thrown
{: .expanded-item-element }

**Item Status:**

☑ Item Reviewed<br>☑ Children linked<br>

**Supported Requests:**

_None_

**Supporting Items:**

- [SWD-001](SWD.md#swd-001){.item-element class="tsf-score" style="background-color:hsl(0.0, 100%, 65%)"}

{% raw %}

**References:**

_None_

{% endraw %}

**Fallacies:**

_None_
