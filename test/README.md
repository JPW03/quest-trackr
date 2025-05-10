# Test Guidelines

## For Schema Tests
File path: `./quest_trackr/{context}/{schema}_test.exs`

These tests will focus on testing the changeset function.

Label the schema unit test module with `@moduletag schema_validation`

For each attribute in the schema that is validated in the changeset:
- Create a describe block with the title of that attribute
- The describe block should contain test cases for:
    - Error present,
    - No error and change present
    - No error and no change (if any)

Do not use the `DataFixtures` module to test associations as they will run code for other changsets, leading to misleading failed tests at the Schema level.
- Opt for minimal database entries instead, e.g. `Repo.insert(%Platform{id: 1})`