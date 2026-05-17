# fortran-stakeholder

Fortran deterministic-first stakeholder rewrite.

Current phase: full local deterministic `classic-six + modern-core` implementation with grouped fallback for later families.

## CLI

```sh
gfortran -std=f2018 -ffree-line-length-none -fall-intrinsics -Wall -Wextra -pedantic app/stakeholder.f90 -o build/stakeholder
./build/stakeholder --list-values
./build/stakeholder --output-format json --focus-family platform_engineering --seed 123
```

Live provider flags fail fast in this tranche.
