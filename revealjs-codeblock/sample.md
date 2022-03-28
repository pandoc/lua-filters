# Pretty Code {#pretty-code data-auto-animate=""}

``` {.jsx .numberLines data-id="code-animation"}
import React, { useState } from 'react';

function Example() {
  const [count, setCount] = useState(0);

  return (
    ...
  );
}
```

Example courtesy of [reveal.js](https://revealjs.com/#/4).

# Even Prettier Animations {#even-prettier-animations data-auto-animate=""}

``` {.jsx data-line-numbers="|4,8-11|17|22-24" data-id="code-animation"}
import React, { useState } from 'react';

function Example() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}

function SecondExample() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}
```

# test line number classes

    unnumbered

``` numberLines
{.numberLines}
```

``` number-lines
{.number-lines}
```

``` {.numberLines .number-lines}
{.numberLines .number-lines}
```

# test data-line-numbers attribute

``` {data-line-numbers="1"}
{data-line-numbers="1"}
```

``` {.numberLines data-line-numbers="1"}
{.numberLines data-line-numbers="1"}
```

# test code tag attributes

``` {.html .another-class}
{.html .another-class}
```

``` {data-trim="" some-other-attribute="" style="border: 1px solid yellow;"}
{data-trim="" some-other-attribute="" style="border: 1px solid yellow;"}
```

# test pre tag attributes

``` {#code}
{#code}
```

``` {data-id="code-animate"}
{data-id="code-animate"}
```

# test line number offset

``` {.haskell .numberLines startFrom="100"}
qsort []     = []
qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++
               qsort (filter (>= x) xs)
```
