<h1>Ch4 Regular expression / SQL</h1>

### Character Classes

| Class    | Description                                                  | Matched Example | Unmatched Example |
| -------- | ------------------------------------------------------------ | --------------- | ----------------- |
| `[abc]`  | Matches a, b, or c                                           | a               |                   |
| `[a-z]`  | Matches any character between a and z                        | x               |                   |
| `[^A-Z]` | Matches any character that is not between A and Z.           | a               |                   |
| `\w`     | Matches any "word" character. Equivalent to `[A-Za-z0-9_]`.  | A, a, 0, _      | - + * / ......    |
| `\d`     | Matches any digit. Equivalent to `[0-9]`.                    |                 |                   |
| `[0-9]`  | Matches a single digit in the range 0 - 9. Equivalent to `\d`. | 1               |                   |
| `\s`     | Matches any whitespace character (spaces, tabs, line breaks). |                 |                   |
| `.`      | Matches any character besides new line.                      |                 |                   |

Character classes can be combined, like in `[a-zA-Z0-9]`.

### Combining Patterns

There are multiple ways to combine patterns together in regular expressions.

| Combo | Description                                                  |
| ----- | ------------------------------------------------------------ |
| `AB`  | A match for A followed immediately by one for B.  Example: `x[.,]y` matches "x.y" or "x,y". |
| `A|B` | Matches either A or B.  Example: `\d+|Inf` matches either a sequence containing 1 or more digits **or** "Inf". |

A pattern can be followed by one of these quantifiers to specify how many instances of the pattern can occur.

| Symbol  | Description                                                  |
| ------- | ------------------------------------------------------------ |
| `*`     | **0 or more occurrences** of the preceding pattern. Example: `[a-z]*` matches any sequence of lower-case letters or the empty string. |
| `+`     | **1 or more occurrences** of the preceding pattern. Example: `\d+` matches any non-empty sequence of digits. |
| `?`     | **0 or 1 occurrence**s of the preceding pattern. Example: `[-+]?` matches an optional sign. |
| `{1,3}` | **Matches the specified quantity of the preceding pattern**. `{1,3}` will match from 1 to 3 instances. `{3}` will match exactly 3 instances. `{3,}` will match 3 or more instances. Example: `\d{5,6}` matches either 5 or 6 digit numbers. |

### Groups

圆括号用于创建groups，和平常的算术表达式中的圆括号类似。 For example, `(Mahna)+` matches strings with 1 or more "Mahna", like "MahnaMahna". Without the parentheses, `Mahna+` would match strings with "Mahn" followed by 1 or more "a" characters, like "Mahnaaaa".

### Anchors

- `^`: Matches the beginning of a string. Example: `^(I|You)` matches I or You at the start of a string.
- `$`: Normally matches the empty string at the end of a string or just before a newline at the end of a string. Example: `(\.edu|\.org|\.com)$` matches .edu, .org, or .com at the end of a string.
- `\b`: Matches a "word boundary", the beginning or end of a word.  Example: `s\b` matches s characters at the end of words, `\bs` matches s characters at the beginning of words.

### Special Characters

The following special characters are used above to denote types of patterns:

```
\ / ( ) [ ] { } + * ? | $ ^ .
```

That means if you actually want to match one of those characters, you have to *escape* it using a backslash. For example, `\(1\+3\)` matches "(1 + 3)".