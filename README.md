# Anki Generators

Small programs to generate Anki decks.

## `src/multiplication-tables.zig`

Generates a CSV file with multiplication tables, without repetitions. You can specify a maximum product and also operands to be ignored:

```
zig run ./src/multiplication-tables.zig -- /tmp/out.csv 100 0 1 10 11
```

This command generates results with a maximum of 100 and ignores tables that include the operands 0, 1, 10, and 11.

For example, the program will generate $`2*5=10`$, but not $`5*2=10`$. If you want both forms, you’ll need to add extra cards to your note types.
