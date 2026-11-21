import re
from pathlib import Path

source = Path("synthesis_reports/soc_top_sram_sky130_mapped.v")
output = Path("physical_design/soc_top_sram_optimized_openroad_named.v")

text = source.read_text()

pattern = re.compile(
    r"sky130_sram_2kbyte_1rw1r_32x512_8\s*"
    r"#\s*\(.*?\)\s*"
    r"\\u_sram\.SRAM_BANKS\[(\d+)\]\.sram_macro\s*\(",
    re.S
)

matches = list(pattern.finditer(text))

if len(matches) != 32:
    raise SystemExit(
        f"ERROR: Expected 32 SRAM instances, found {len(matches)}"
    )

banks = sorted(int(m.group(1)) for m in matches)

if banks != list(range(32)):
    raise SystemExit(f"ERROR: Unexpected SRAM bank indices: {banks}")

text = pattern.sub(
    lambda m: (
        "sky130_sram_2kbyte_1rw1r_32x512_8 "
        f"sram_macro_{m.group(1)} ("
    ),
    text
)

output.write_text(text)

print("Conversion successful")
print("SRAM macros:", len(matches))
print("Output:", output)
