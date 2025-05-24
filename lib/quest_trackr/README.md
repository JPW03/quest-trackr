# QuestTrackr Backend

## Data Rules

For internal data, representing database entries, stored as maps, the keys must be atoms, not strings.
- [Why?](https://stackoverflow.com/questions/34446221/atom-keys-vs-string-keys-in-phoenix)
- Schema `changeset` functions should only parse atom keys, not strings.

The only exception to the above rule is data received from the IGDB API.
- It is the purpose of the `QuestTrackr.Data` context, when converting IGDB data to database data, to convert the string keys to atom keys.

## Changeset Rules

Never set `has_many` associations in changesets, set the corresponding `belongs_to` instead.

Always use `_id` fields to assign non-many-to-many associations.

For many-to-many associations, assign them via the changeset using `maybe_put_assoc` attaching the list of structs to the attributes passed to the changeset.
- Avoid using `cast_assoc` as that will modify the structs you are trying to associate to.

# Schema Rules

All schemas have an implicit `id` field which acts as the primary key, unless another field is explicitly declared as the primary key.

Although it would be intuitive, do not use composite primary keys, for example making the primary key of `game_in_library` a composite of `library_id` and `game_id`.
- It causes a lot of compatibility issues with Ecto's functions.
- It's also generally less efficient from a database query perspective.
