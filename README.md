# dbt example Project
This repository houses the code for the example dbt cloud project.

## Table of Contents
- [About](#about)
- [Getting Started](#getting-started)
  - [Cloud Setup](#cloud-setup)
    - [GitHub Link](#github-link)
    - [Snowflake Credentials](#snowflake-credentials)
  - [Local Setup](#local-setup)
    - [Configuring git](#configuring-git)
    - [Configuring your IDE](#configuring-your-ide)
- [Development Process](#development-process)
- [Contracts](#contracts)
- [Exposures](#exposures)
- [Testing Suite](#testing-suite)
- [Dynamic Warehouse Selection](#dynamic-warehouse-selection)
- [Versioning](#versioning)
- [Style & Standards](#style--standards)
  - [High-level Architecture](#high-level-architecture)
    - [Medallion Architecture](#medallion-architecture)
  - [Model Naming](#model-naming)
  - [Field Naming](#field-naming)
- [Common Commands](#common-commands)
  - [Essential Commands](#essential-commands)
  - [Development Workflow Commands](#development-workflow-commands)
  - [Debugging Commands](#debugging-commands)
- [Resources](#resources)
  - [dbt Documentation](#dbt-documentation)
  - [Snowflake Resources](#snowflake-resources)
  - [Internal Resources](#internal-resources)
  - [Git Resources](#git-resources)

## About


## Getting Started
### Cloud Setup
In order to develop within our dbt environment you'll first need to ensure your dbt Cloud account is properly configured.

Sign in to dbt Cloud at: [https://auth.cloud.getdbt.com/u/login](https://auth.cloud.getdbt.com/u/login). Benjamin Engen will get your login configured for you.

You'll need to set up your credentials for your connections to both Snowflake and GitHub. Ensure that you have been given access to these platforms first.

Our GitHub repositories can be found here, ensure you can see them.

You'll log into Snowflake via Okta so it can be accessed from your Okta user applications page.

#### GitHub Link
Once you've [signed in to dbt Cloud](https://auth.cloud.getdbt.com/u/login) click on your name on the bottom-left of the web UI and choose 'Your profile' from the pop-up. Within the main menu of this page is a section called 'Linked accounts'. It should have an option for GitHub and next to that a button called 'Link'. Click the 'Link' button and follow the prompts to sign in to GitHub and complete linking your accounts.

#### Snowflake Credentials
This repository connects to Snowflake using a dedicated, dbt service account. You'll make use of the account called 'DBT_SVC'. To use this account you'll need access to both the public and private pairs of the key.

Now, return to your dbt Cloud account. Once again click on your name in the bottom-right and then 'Your profile'. Click on the 'Credentials' heading in the user settings menu on the left. Choose this project.

This will bring up a pane to configure credentials on the right. Click 'Edit' in the bottom right and set the values as so:
- Account: 
- Role: DBT_DEV
- Database: LOCAL_ (your first initial and last name), ie LOCAL_BENGEN
- Warehouse: XS_WAREHOUSE
- Auth method: Key pair
- Username: DBT_SVC
- Private key: The _full_ contents of your `rsa_key.p8` file that you created earlier including the `---- BEGIN PRIVATE KEY ---` headers and footers.
- Private key passphrase: The passphrase you set when creating your private key.
- Schema: This follows the format 'dbt_' your first initial, your last name. For example, for Ben Engen this value is 'dbt_bengen'.
- Target name: local
- Threads: 6

Test your connection and save these settings.

If you only plan to develop within the web UI, you're now fully setup. You can choose 'Studio' from the left-hand navigation bar and begin browsing the files that comprise our dbt project.

If you have more sanity and want to develop locally using VSCode continue to the next section.

### Local Setup
#### Configuring git
Installing git is very easy. Open your terminal and type `brew install git`. You can then verify the installation by entering `git --version`.

You'll then need to configure the connection between your local git and GitHub. This will be done using an SSH key.

[To create a key for GitHub follow their instructions here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key) and complete the steps for 'Generating a new SSH key' and 'Adding your SSH key to the ssh-agent'.

Once you've created your key file you should then follow [these GitHub instructions to attach that key to your account for access](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

Now it's time to further test your git configuration by cloning the repository to your local machine. Go to the repository in GitHub and click the green 'Code' dropdown button, in the 'Clone' section toggle to the SSH tab and copy the string.

Open your terminal and navigate to the folder where you'll store your code projects. I recommend something like `/USER/Documents/projects`. Within this directory in the terminal type `git clone` and paste the SSH clone string you copied previously. If successful you should be able to navigate to the directory in Finder or type `ls` and see a new folder called 'dbt-example-repo'.

#### Configuring your IDE
This project utilizes dbt fusion. So, in order to avoid conflicts between the different flavors of dbt (core, cli, fusion) you'll need to do local development inside a VSCode Dev Container.

Start by [configuring CLI access within the dbt Cloud UI](https://wt028.us1.dbt.com/settings/profile/cloud-cli).

Within dbt Cloud you'll see an option for 'Set up CLI' on the bottom-left of the screen on the main navigation pane. **You will ignore all but one section in these instructions. Do not follow the instructions in the 'Install' section.** Skip down to 'Configure Cloud authentication'. This simply requires that you click the 'Download CLI configuration file' button and save it at `~/.dbt/dbt_cloud.yml`. This is a companion directory to your `.ssh` directory. The `.ssh` directory holds your keys and the `.dbt` directory holds your dbt secrets now contained within the file you just downloaded.

To begin setting up your local environment you'll need to download and install three applications:

1.  [VSCode](https://code.visualstudio.com/download)
2.  [The Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VSCode
3.  [Docker Desktop](https://www.docker.com/products/docker-desktop/)

Once you've installed all three, open Docker Desktop. Then open VSCode and open the repo folder that you cloned earlier via 'File > Open Folder'. If you've successfully installed the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) inside VSCode hit 'Cmnd + Shift + P' to open the command bar. Begin typing "Open Folder in Container..." and select that option when it appears in the bar. You'll receive two further prompts in the command bar, the first asking which folder to open. Select the repo folder. The second will ask which container configuration to use, choose 'VSCode Local Dev Container'. The first time you do this it will likely take some time to build and launch the container.

Once the container launches, open a new terminal **inside VSCode**. Verify your connection to dbt Cloud by running the command `dbt env show`. This should return information about our dbt Cloud configuration. Then run `dbt debug` to ensure your connection to Snowflake is working. 

Once both of these pass you've successfully configured your development environment.

## Development Process
If you're new to git or if you've only used it on small teams or for streamlined development workflows Ben highly recommends taking this Udemy course: [The Git & Github Bootcamp](https://www.udemy.com/course/git-and-github-bootcamp/).

Generally speaking there should be a 1:1 relationship between GitHub pull requests and Jira tickets. Every ticket/pull request should represent the full implementation of a feature. In other words, if we need to revert a pull request we should be able to do so with one command and without fear that the reversion will break anything or leave nonfunctioning code behind in the `main` branch.

Begin by creating a new branch. Branches should be named according to the following convention:

```text
be_DATA-215_expose_zip_on_model
```

Branches should be prefixed with the developers initials, then the Jira ticket number should be explicitly referenced, followed by a short description in snake case. This pattern makes it easy to identify who is working a branch and it will enable Jira to automatically tie development work to the tickets where it originates.

To create a new branch run the command: `git switch -c be_DTT-215_expose_zip_on_model`.

The `-c` parameter is the instruction to create a new branch named according to what follows.

When working and making commits on your branch, the mindset should be one of making complete commits. Preserving waypoints that can, and indeed may need to be, reverted without breaking anything.

Once you have finished making edits to files you can run the command `git status` to see a list of changed files. To stage them for commit type `git add *` or `git add <filepath/filename>` to only add a specific file.

You can type `git status` again to verify the correct files are staged for commit. The changes can then be comitted by typing `git commit -m "a short description of the commit"`.

For larger projects, you should push your changes to GitHub at least once a day. To push your changes to GitHub so they can be merged or just to save your progress you'll first establish a remote branch by typing `git push --set-upstream origin be_DRR-215_expose_zip_on_model`. After you've established the remote branch you can then just run `git push` to add new updates to GitHub.

Once you're finished and you've `push`d all your work to GitHub, navigate to the repository there and then go to the 'Pull requests' tab and create a 'New pull request' using the green button. Enter a description of the changes and then post a link to the pull request in Slack asking your resident Analytics Engineer for approval. Once the request is approved you're good to merge.

## Contracts
Models that are exposed outside of dbt to users or services should have contacts enforced. This means that all columns exposed by that model must be listed in the accompanying `yml` file and those columns must have explicit values set for 'data_type' and any applicable 'constraints' must be set as well. A good example of this can be seen in `int_auth0_users.yml`. The configuration for contracts looks something like:
```yaml
models:
  - name: int_auth0_users
    description: '{{ doc("int_auth0_users") }}'
    config:
      contract:
        enforced: false
      tags: ["auth0", "incremental", "intermediate", "users"]
    
    columns:
      - name: _DBT_PROCESSED_AT
        description: "{{ doc('_dbt_processed_at') }}"
        data_type: timestamp_tz
        constraints:
          - type: not_null
        tests:
          - not_null
```

## Exposures
Mart (mrt), Reverse ELT (elt), and any other model used by a system outside of dbt is required to have documented exposures.

Exposures create a node in the dbt docs DAG that shows external dependencies for models and can help us manage changes that could impact downstream users. For a template to follow for configuring an exposure see `./models/marts/mrt_dbt_model_invocations.yml`. Be sure to maintain the same field order (roughly alphabetical) as observed in that example.

## Testing Suite
This repo makes use of rigorous unit testing to ensure the integrity of user-facing data sets. As such, additional configuration is required for base (bse) models ingesting data and for any models that expose data to sources outside dbt, most likely mart (mrt) and reverse-ELT (elt) models.

At a high level, testing works by ingesting a small set of known and controlled data via series of `csv` seeds where there is a companion seed for each base (bse) model. During testing the full DAG is built from these small sample files in the 'DBT_TEST' database. There is a second set of seeds which contain the data as it is expected to be exposed to outside users and applications. There is a companion `csv` for every model of this type. These `csv`s are compared to the actual output of the model in 'DBT_TEST' and tests only pass if they are equal.

This testing configuration means that whenever adding a base (bse) model you must also create a companion `csv` in `./seeds/input/`. The `csv` should be named with 'seed__' as the prefix, then the source, schema, and model name. The prefix, source, schema and model name should all be seperated by two underscores (_). For example, the model `bse_snowflake__query_attribution_history` would have a companion seed `seed__snowflake__account_usage__query_attribution_history`.

Datatype differences can arise when data is ingested via `csv` vs. directly from the source system. As such, it's important to configure the expected datatypes of each field in the seed files in `./seeds/properties.yml`. Adhere to the existing pattern in this file.

The seed files should be no larger than about 10 records for each base model. Since this is source data being ingested these files can easily be created as direct exports from the source.

Once all of the companion seeds for base models are in place you can generate the expected output seed easily by just running the DAG through to the model you're exposing outside dbt with `dbt build --target=test --full-refresh`. `dbt build` will ensure that the seeds are ingested first, unlike `dbt run` which will only run the models.

Once the run is complete you can export the data in your user-facing model into a `csv`. Place that `csv` in the folder `./seeds/expected/`. This file should have the same name as the model being tested but be prefixed with 'expected_'. For example, the companion expectation seed for the model `mrt_dbt_model_invocations` would be `expected_mrt_dbt_model_invocations`. You should also define the seeds datatypes in `./seeds/properties.yml` as well.

Unlike our more prolific data tests, these unit tests are only meant to run in 'DBT_TEST' at the point that a pull request is created. As such, they receive some special configuration. This configuration takes place within the user-facing model's accompanying configuration file. To extend the above example, that would be `mrt_dbt_model_invocations.yml`. Add the unit test by defining a model-level test in the model config block. For `mrt_dbt_model_invocations` that looks like so:
```yaml
models:
  - name: mrt_dbt_model_invocations
    description: '{{ doc("mrt_dbt_model_invocations") }}'
    config:
      tags: ["incremental", "mart"]
    tests:
      - table_equality:
          config:
            severity: error
          arguments:
            compare_model: ref('expected_mrt_dbt_model_invocations')
```

Verify that your test additions are working by running `dbt build --target=test --full-refresh`. Once this run completes with all tests passing you are clear to open a pull request to merge your changes. Going forward, every time someone opens a new pull request a Github action will run and require all these tests to pass before the pull request can be merged.

## Dynamic Warehouse Selection
By default, models in this repository use an extra-small Snowflake warehouse, 'XS_WH'. However, this repository supports allocating warehouse size at the model level. As such, every model should have the macro for warehouse selection included as part of its `config` block on the first line of the model file. For example,
```sql
{{
    config(
        snowflake_warehouse=dynamic_warehouse_selection(),
        materialized='table'
    )
}}
```
This calls the macro that sets warehouse sizes by model. The definition for which warehouse a model should use resides in `macros/dynamic_warehouse_selection/generate_warehouse_size.sql`. This file is a dictionary of model names accompanied by a list of two warehouses. The first warehouse in the list is the name of the warehouse to use for 'full-refresh' jobs. The second warehouse in the list is the warehouse to use for all other jobs.

All models should start out using 'XS_WH', so they don't necessarily need to be included in `generate_warehouse_size.sql` from the start. However, new models should be monitored in the dbt Model Invocations Report after they're created. Our goal is to choose a warehoue for each model that minimizes Snowflake credit consumption. If a model is taking a long time to build using the extra-small warehouse, we should bump that model up to a small warehouse, 'S_WAREHOUSE' for two weeks and then review the performance again. If it is consuming more credits than on the extra-small warehouse we can lower it again, or if it is still running for a long time we can bump the warehouse up again and reasses.

This is an iterative process that will take some time to dial in for each model. As such the model performance report should be monitored weekly for potential changes required to keep our Snowflake credit consumption to a minimum.

## Versioning

## Style & Standards
### High-level Architecture
#### Introduction
We’ll adopt a combination of common architectures: medallion, entity-oriented star schema, and activity schema. Each of these three applies to a slightly different element of the architecture. They’ll fit together like so:

#### Medallion Architecture
This describes the highest-level architectural abstraction that we’ll apply to our data warehouse. The term “Medallion Architecture” is one that every data team follows intentionally or not. It describes a three-step process of data processing through the layers:
- Bronze: Standardizing data
- Silver: Creating normalized data models
- Gold: Creating de-normalized presentation tables for business intelligence

The Medallion Architecture of the data model describes the “where,” giving us a framework for where certain kinds of data transformations should be carried out.

##### Bronze
Bronze layer models are those that the [dbt project guide](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview) refers to as “staging” models. We use the term “base” instead of “staging” to disambiguate from our application's staging environment.

The purpose of Bronze models is to ingest data from source systems, apply standardization to field names and data types, synchronize time zones, and decode any application-encoded data. The goal of the Bronze layer is to create an identical copy of the source data itself, while standardizing the structure of the data.

##### Silver
The silver layer is the point at which data is normalized into a usable table structure. At this stage in our data model, we generally shouldn’t be modifying the data itself, but rather organizing it into a flexible and interpretable structure. Within this layer of transformations, we’ll build two traditional data models depending on the data being modeled: an entity-oriented star schema and/or an activity schema. Because this layer deals with modifying the structure of the data and combining data from different sources, it is the most complex.

To facilitate these transformations, this layer contains several kinds of models:

**Activity (act) models**

These models are siblings of fact models. They are identical in that they contain records of immutable actions. But what sets activity models apart from fact models is that activity models can contain many different types of actions, as opposed to fact models, wherein all actions must be of a single type. An example of an activity model might be a string of user actions of different types: a user clicks an ad, starts a session, has a page view, views an ad, starts a new session, views a page, views a page, binds a policy. In this example, we’re combining four different types of activities across three domains into one model. Because of their size and complexity, models of this type are to be avoided where possible, but they’re critical for things like marketing attribution and closed-funnel analysis.

**Bridge (brg) models**

These models exist to facilitate complex joins across multiple tables. These tables contain nothing more than keys from the linked tables and the join logic to align them. These are particularly useful for one-to-many (or vice versa) joins where we need to resolve the same record given multiple different inputs.

**Entity (ent) models**

These models contain all of the attributes of a business entity. Entities are things that can act or be acted upon. For example, a user, an ad, or a policy. These are directly analogous to traditional dimension models, but the entity constraint prevents these tables from proliferating out of control and enhances the interpretability of the tables themselves.

**Fact (fct) models**

These models are a staple of data modeling. These tables contain immutable records of actions – things that entities can do or have done to them. The most classic example of a fact table is a series of financial transactions. Fact models contain only one type of transaction. For example, payments for a policy.

**Intermediate (int) models**

These models only need to be exposed to be leveraged by other models downstream or for quality assurance purposes. For example, creating a user record from a source system may require unifying several tables from that source system and creating a table representing that source system's users before integrating it with our canonical user table.

**Slowly changing, type II dimension (scd) models**

These models generate historic snapshots of entity models. Their purpose is to maintain a historic record of the state of entities at a particular time. The key here is that these models are meant to be applied to “slowly-changing” dimensions. In other words, dimensions that don’t change often, like a user’s address. SCD models work by creating a new row for an entity every time any field associated with that entity changes. As such, if these models are applied improperly, their output can explode, leading to significant storage and computation costs.

Used correctly, though, SCD models are essential for establishing audit trails and creating views of the data as it existed at a certain point in time – particularly valuable for finance use cases.

##### Gold
Gold layer models are those exposed to business intelligence applications and business analysts. Gold layer models join together all the contextual data required for analysis into singular denormalized tables. This is also where aggregations are performed. For example, pre-calculating daily values for metrics to reduce query lag time in business intelligence applications. But, the most important (and oft overlooked) purpose of the gold layer is that this is the stage at which all business logic is applied.

It’s important to centralize business logic as much as possible because business logic is often changeable. This type of logic includes things like re-categorizations or allocations. Because business logic changes more than other attributes of a data model, it is best placed at the “end” or “bottom” of your data model or DAG (directed acyclic graph) so that revisions to business logic have no impact on “downstream” models or calculations. Additionally, business logic is often the source of most stakeholder enquiries, and locating this logic in a single place can speed the question and answer cycle.

**Calendar (dte) models**

These models are aggregation models that surface pre-calculated metrics for every date. These models are valuable for pre-calculating metrics and aggregations to reduce query time and the cost associated with running the business intelligence layer. However, these models also reduce flexibility, so they are best avoided until the overall size of the data being queried becomes large enough to demand their creation.

**Mart (mrt) models**

These models are any model containing un-aggregated data that are exposed to the business intelligence application. These models could be a simple `select *` from an entity model or a pre-joined table that matches facts and entities together. These tables are where business logic should reside.

**Reverse ELT (elt) models**

These are models that compose data into the table structure required to pass data back out of the data warehouse and into first or third-party applications. For example, creating a record of clients to load into SugarCRM or records of users to load into Iterable.

### Model Naming
As discussed in the High-level Architecture section, we utilize the following model types with the accompanying naming conventions:
 - Activity (act) - Prefixed 'act_'
 - Calendar (dte) - Prefixed 'dte_'
 - Base (bse) - Prefixed 'bse_'
 - Bridge (brg) - Prefixed 'brg_'
 - Fact (fct) - Prefixed 'fct_'
 - Intermediate (int) - Prefixed 'int_'
 - Mart (mrt) - Prefixed 'mrt_'
 - Reverse ELT (elt) - Prefixed 'elt_'
 - Slowly changing, type II dimension (scd) - Prefixed 'scd_'

Generally speaking, model names should be plural to more accurately capture the contents of the table. For example, a table of policies contains policIES, plural. We don't have tables that contain just one policy, thus we shouldn't name models "policy." Apart from prefixes, there's a lot of leniency in naming models with the **exception** of base models. Because, base models are meant to map precisely to source tables they need to be named according to a particular formula, for example:

`bse_snowflake__query_history`

It carries a prefix of course, followed by one '\_' underscore as is the standard for all models. This is followed by the snake-case exact name of the source system. In this example this is 'snowflake'. This is followed by _two_ '_' underscores to seperate the source name from the table name. Then we add the _exact_ table name, also in snake-case. Here: 'query_history'.

### Field Naming
All fields output by this repository should follow a standardized naming convention using prefixes to indicate the type an purpose of each column/field.

**Field Naming Prefixes:**
- **`dim_*`**: Dimensional attributes used for grouping and filtering. In general these are fields an Analyst might want to segment a report on. That means they generally shouldn't have more than 500 distinct values. If an input field contains more than 500 distinct values, that level of cardinality indicates it should like be given the 'info_' prefix.
- **`met_*`**: Metric fields containing numeric values for analysis. Just because a field is a number does not necessarily mean that it is a 'met_', and not a 'dim_', field. An easy test to apply is to ask yourself if a sum of all values in this field would be a valuable piece of information. For example, one might sum a column of zipcodes but the output of that sum would be meaningless.
- **`info_*`**: Fields that contain unique or verbose information. The most classic example of a 'info_' field is a person's name. But this could also be things like phone numbers, emails, or lengthy descriptions of an accompanying 'dim_'.
- **`is_*`**: Boolean flags indicating true/false conditions.
- **id fields**: ID fields are slightly more nuanced, these fields should be given a two-letter prefix that can help identify the source system. This helps trace lineage and group common IDs together. For example, identifieres produced by Snowflake should be prefixed 'sf_' for Snowflake as in the case of `sf_user_id`.

These prefixes make it immediately clear whether a field is an identifier, a dimension for grouping, a metric for aggregation, a complex object, or a boolean flag, improving code readability and reducing ambiguity in downstream transformations.

In order to maintain model readability, fields should be listed in a consistent order within each `select` statement. That order is:
1. IDs/Keys/Identifiers
2. Date/Time Dimensions
3. Dimension, 'dim_', fields.
4. Boolean dimension, 'is_', fields.
5. Metric, 'met_', fields
6. Info, 'info_', fields.

Those groupings should be indicated with code comments or coderegions for larger models. Fields should be organized alphabetically by their final output name/alias within each of those sections.

## Common Commands
### Essential Commands

```bash
# Verify dbt Cloud connection
dbt env show

# Test connection to Snowflake
dbt debug

# Run all models in your project
dbt run

# Run a specific model
dbt run --select model_name

# Run a model and all its downstream dependencies
dbt run --select model_name+

# Run a model and all its upstream dependencies
dbt run --select +model_name

# Run all models in a specific directory
dbt run --select models/incoming_sources/

# Run modified models and their dependents
dbt run --select state:modified+

# Test all models
dbt test

# Test a specific model
dbt test --select model_name

# Compile models without running them
dbt compile

# Generate and serve documentation
dbt docs generate
dbt docs serve
```

### Development Workflow Commands

```bash
# Build specific models with their tests
dbt build --select model_name

# Run models with full refresh (for incremental models)
dbt run --select model_name --full-refresh

# Parse project to check for errors
dbt parse

# List all models in the project
dbt list

# Show dependencies for a specific model
dbt list --select +model_name+ --output name

# Run models matching a tag
dbt run --select tag:daily

# Compile and show SQL for a specific model
dbt compile --select model_name
# Then check target/compiled/ for the compiled SQL
```

### Debugging Commands

```bash
# Show environment and configuration details
dbt env show

# Run with verbose logging
dbt run --select model_name --debug

# Validate project structure
dbt parse --no-partial-parse
```

## Resources

### dbt Documentation
- [dbt Documentation](https://docs.getdbt.com/docs/introduction) - Official dbt documentation
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices) - Recommended patterns and approaches
- [Jinja Template Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates/) - For writing macros and advanced logic

### Snowflake Resources
- [Snowflake Documentation](https://docs.snowflake.com/) - Official Snowflake docs
- [Snowflake SQL Reference](https://docs.snowflake.com/en/sql-reference) - SQL syntax and functions
- [Key Pair Authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth) - Setting up secure authentication

### Internal Resources
- [dbt Cloud Login](https://auth.cloud.getdbt.com/u/login) - Access to dbt Cloud environment

### Git Resources
- [The Git & Github Bootcamp](https://www.udemy.com/course/git-and-github-bootcamp/) - Recommended course for git workflows
- [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) - Configuring SSH authentication
- [GitHub Pull Request Documentation](https://docs.github.com/en/pull-requests) - Creating and managing PRs
