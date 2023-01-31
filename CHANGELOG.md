# Change Log

## Versions

- [1.15](#115)
- [1.14](#114)

## 1.15

### Resolved Issues

- Added `AddedContactsTimer` that starts whenever an `Added Contact` phonebook event is received. If only one contact is added before the timer expires, the plugin will ignore that contact, but will increment `contactsAddedSinceLastFetch`, which tracks the number of single contacts added, in total, since the last phonebook fetch. A manual phonebook fetch is required to update the phonebook. If more than one contact is added, we will assume the Zoom Rooms Conferencing software has been restarted and the contacts are being imported to the Zoom Rooms Conferencing software and we should wait for that to finish; the `AddedContactsTimer` will not expire until 10 seconds after the last `Added Contact` event, and will then trigger a fresh import of the phonebook.

- On SSH connection, set `ignorePhonebookResponses` to `true`. `ignorePhonebookResponses` acts as a guard clause for `PhonebookListResult` events and will not call `UpdatePhonebook()` if set to `true`. `ResetPhonebookList()` sets `ignorePhonebookResponses` to `false`. This should prevent stale `PhonebookListResult` events from interrupting the contacts import flow when the plugin reconnects to the Zoom Rooms Conferencing software and the communications are not in a predictable state.

- Call `Initialize()` on SSH `Timeout`, `Closed`, `Reconnect`, `Error`, `LoginFailed` events.

## 1.14

### Resolved Issues

- Added 'Contacts Processed' control for visibility of the number of unique contacts that have been registered.
- [ZR CSAPI not responding](#zr-csapi-not-responding)
- Waiting for phonebook when it is too slow blocks plugin use. Made it fetch in the background.

#### ZR CSAPI not responding

1. ZR Software will occasionally not respond to the `zCommand Phonebook List` command if the `limit` parameter is too high - tested with `limit: 25` (misses a lot of responses) and `limit: 50` (doesn't even respond before the 10s socket timeout).
2. `PhonebookTimer` then times out because of no response, and re-sends the last command.
3. ZR Software will respond with the response that was not transmitted back in step 1.

This throws the sequence out of sync if the unexpected response is not handled properly.

~~It is being handled be checking the `Offset` field in the response vs the `offset` global variable; if they are not the same, the response is unexpected and therefore it has arrived before the `commandQueue` has dequeued. The plugin then clears the `commandQueue` and re-sends the last command again.~~

- With `limit: 5` it doesn't miss responses, but it is too slow to import a large phonebook. It is actually quicker to miss some responses and handle them again.. settling with `limit: 20` seems to be the sweet spot.
- Timed import of 19,147 contacts with `limit: 20` = 1m 35s
- While in a call with backgroun importing, it takes longer.