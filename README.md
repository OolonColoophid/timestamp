#  Timestamp

This is an implementation of a time stamp, based on a Ruby script by Ioa Petra'ka, that produces output like this:

`21308;456`

My primary use case is creating time stamps that can connect otherwise separate text. For instance, a journal entry could be given a time stamp; we then use the same time stamp in some source code to indicate that it is associated with the journal entry.

It should be straightforward to search to for time stamps.

## Overview

```
$ timestamp -h
OVERVIEW: Creates a code representing the current date and time.

As an example, a stamp might be "21308;456". When this is created, it is copied
to the clipboard.

This means:
- 21st year (of century)
- 308th day of the year
- ; = Thursday
- 0.456 is the metric time of the day in GMT

Sunday to Saturday are represented by: /.:,;'\

USAGE: time-stamp [--year-hidden] [--day-hidden] [--week-day-hidden] [--time-hidden] [--clipboard-not-used] [--stamp <stamp>]

OPTIONS:
  -y, --year-hidden       Hide year.
  -d, --day-hidden        Hide day.
  -w, --week-day-hidden   Hide weekday.
  -t, --time-hidden       Hide time.
  -c, --clipboard-not-used
                          Do not copy to clipboard.
  -s, --stamp <stamp>     Parse a (full) timestamp.
  --version               Show the version.
  -h, --help              Show help information.
```

```
$ timestamp
23004,378
```

```
$ timestamp -s 23004,378
Wednesday, 4 January, 2023, at 9:04am
```

```
$ timestamp -y
004,374
```

```
$ timestamp -d
23,374
```

```
$ timestamp -w
23004374
```

```
$ timestamp
23004,375
$ pbpaste
23004,375
```

```
$ timestamp --version
1.0a
```

## Espanso

At Ioa's suggestion, I have two simple keyboard shortcuts set up to use `timestamp` at the point of need.

[Espanso](https://espanso.org/) uses a YAML file for matching keyboard triggers to actions. This is the location of the 'matching' file on my system:

```
$ pwd
/Users/ianuser/Library/Application Support/espanso/match
```

Let's looks at the file:

```
$ tail -n 18 base.yml

  # Print the output of the timestamp command
  - trigger: ":ts"
    replace: "{{output}}"
    vars:
      - name: output
        type: shell
        params:
          cmd: "timestamp"

  # Print the clipboard's current timestamp as human readable
  - trigger: ":tp"
    replace: "{{output}}"
    vars:
      - name: output
        type: shell
        params:
          cmd: "timestamp -s `pbpaste`"
```

When I type `:ts` I get a time stamp like `23004,393`. This is now on the clipboard automatically. If I like, I can create a human readable version using `:tp`: `Wednesday, 4 January, 2023, at 9:25am`.

### Thanks

To Ioa.

### Licence

[MIT License](https://opensource.org/licenses/MIT).
