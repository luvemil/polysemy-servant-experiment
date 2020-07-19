# polysemy-servant-experiment

This repository contains some experiment for running Servant using Polysemy for effectful computations.

In `Effects/Storage.hs` there is a definition of a basic storage with a single resource (Post). There are two implementations:
 - `runStorage`: dummy
 - `runStorageToState`: uses a map inside a state to hold the values in memory

In `Lib.hs` there are two main functions that use the implementations above respectively.

In order to select which implementation to use, call with

```
stack run -- --mode MODE
```

where `MODE` can be one of `pure`, `io`, `reader` (defaults to `pure`).

# TODO

- remove unnecessary imports/pragmas