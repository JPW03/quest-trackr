# QuestTrackr Backend

## Data Rules

For internal data, representing database entries, stored as maps, the keys must be atoms, not strings.
- [Why?](https://stackoverflow.com/questions/34446221/atom-keys-vs-string-keys-in-phoenix)
- Schema `changeset` functions should only parse atom keys, not strings.

The only exception to the above rule is data received from the IGDB API.
- It is the purpose of the `QuestTrackr.Data` context, when converting IGDB data to database data, to convert the string keys to atom keys.

## Changeset Rules

For associations, do not use `cast_assoc` as this has the sideeffect of editing the struct to be associated. Prefer `put_assoc` whenever possible.