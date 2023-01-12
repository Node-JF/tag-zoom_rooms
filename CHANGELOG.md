# Change Log

## 1.14

- Added 'Contacts Processed' control for visibility of the number of unique contacts that have been registered.

### Issue

1. ZR Software will occasionally not respond to the `zCommand Phonebook List` command if the `limit` parameter is too high - tested with `limit: 25` (misses a lot of responses) and `limit: 50` (doesn't even respond before the 10s socket timeout).
2. `PhonebookTimer` then times out because of no response, and re-sends the last command.
3. ZR Software will respond with the response that was not transmitted back in step 1.

This throws the sequence out of sync if the unexpected response is not handled properly.

It is being handled be checking the `Offset` field in the response vs the `offset` global variable; if they are not the same, the response is unexpected and therefore it has arrived before the `commandQueue` has dequeued. The plugin then clears the `commandQueue` and re-sends the last command again.

- With `limit: 5` it doesn't miss responses, but it is too slow to import a large phonebook. It is actually quicker to miss some responses and handle them again.. settling with `limit: 20` seems to be the sweet spot.
- Timed import of 19,147 contacts with `limit: 20` = 1m 35s
