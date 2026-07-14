---
name: 'dbt_doc_generation'
argument-hint: 'Skill to create the .yml and .md dbt documentation for the selected .sql dbt model.'
description: 'Skill to create the .yml and .md dbt documentation for the selected .sql dbt model.'
---

Generate the `.md` and `.yml` dbt documentation files for [${fileBasename}](${file}).

* Include all fields output by the referenced dbt model in the `.yml` `columns` config. Be sure to list them in alphabetical order.
* Check to ensure that all fields defined in the new `.yml` file have matching docstrings in the associated `field_dictionary.md` file. If any fields are missing from `field_dictionary.md` add them and maintain the existing alphabetization of the fields listed in `field_dicationary.md`.
* If the user has provided a table or list of field definitions, use the user provided definitions in `field_dictionary.md`. If you have not been provided a definition for a field use "Definition not provided by Engineering." as the docstring definition.
* You may use [bse_snowflake__query_history.yml](../../models/incoming_sources/snowflake/docs/bse_snowflake__query_history.yml) as an example for the `.yml` file.
* You may use [bse_mongo__query_history.md](../../models/incoming_sources/snowflake/docs/bse_snowflake__query_history.md) as an example for the `.md` file.
* Ensure the `.md` file you create with the table description contains no code snippets or code examples of SQL code or any other language.
* If you create bullet or number lists always end the list item with a period.
* You may find more information about this repository and dbt project configuration in [README.md](../../README.md)
