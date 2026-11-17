# DSD-8 Bug Log

| ID | Symptom | Found by | Root cause | Fix/evidence |
|---|---|---|---|---|
| B01 | I/O requests could be confused during delayed access | Conformance review | CPU needed direction gating while the shared controller exposes both request controls | `dsd8_cpu.v` gates `io_rd`/`io_wr`; SLOW_ECHO passes |
| B02 | Local test runner could accept a failed simulator | Review | Runner checked printed PASS but not the simulator return code | `run_unit_tests.py` now reports non-zero simulation exits |
| B03 | UART receive path had no stimulus or observable TX event | Integration review | Reference model only returned a permanently empty RX status | Added deterministic RX injection and TX event outputs; UART integration bench passes |
| B04 | New top-level test expected active-low display enables incorrectly | Unit test | `an` is the inverse of `seg_enable`; reset blanking is `0xF` | Corrected `tb_dsd8_top.v`; full unit suite passes |
| B05 | A first draft of the 256-iteration test did not change its loop condition | Conformance diff | The loop compared a counter that never reached the tested condition | Reworked T30 to use the zero result of an 8-bit wrapping ADD |
| B06 | Generated CPU UART image was truncated to 8 bits | Integration test | Testbench instruction image was declared `[7:0]` instead of `[15:0]` | Corrected declaration; polling UART test passes |

Durations were not measured during the original development session, so they
are intentionally not fabricated. Future entries should record elapsed time
with the discovery method and the test that prevented recurrence.
