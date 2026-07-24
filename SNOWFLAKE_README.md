# Snowflake Terraform Infrastructure
This repository manages Snowflake infrastructure using Terraform.


This repository is meant to manage the core infrastructure of Snowflake:
- Grants / Privileges
- Roles
- Service Accounts
- Warehouses

Most data in the Snowflake instance is ingested or transformed by third-party tools like Fivetran and dbt. As such, it is best to leave the actual data and its structures to be managed by these tools within Snowflake.

This repository is intended primarily to manage roles and grants, as these can spiral into overwhelming complexity. Breaking changes to privileges can have a significant blast radius, which demands the ability to easily roll back damaging changes.

The creation of human users should continue to be managed by system admins as these require SSO integration. However, all roles and role grants to those users should be managed via this repository.

## Table of Contents
- [Getting Started](#getting-started)
- [Structure](#structure)
- [Style & Standards](#style--standards)
- [Terraform Configuration](#terraform-configuration)
- [Modules](#modules)
  - [Account Role to User](#account-role-to-user)
  - [Ownership to Role](#ownership-to-role)
  - [Privilege to Role](#privilege-to-role)
  - [Roles](#roles)
  - [Users](#users)
  - [Warehouses](#warehouses)
## Getting Started
### SSH Keys
**Before opening the repository in VSCode**

This repository utilizes a Snowflake service account called TERRAFORM_SVC. Before you begin, you should access the public and private SSH keys for this account.

Save the private key to your `.ssh` folder as `~/.ssh/snowflake_tf_snow_key.p8`.

Save the public key to your `.ssh` folder as `~/.ssh/snowflake_tf_snow_key.pub`.

**Confusing steps here**

Terraform is particular about PEM formatting when utilizing keys. As such, the steps you just took are to grant Terraform proper access to the keys it will be using to access Snowflake. But, you also need a different set of keys for Terraform to utilize: the public keys for your service accounts.

Open the file `./.env.template` and resave it as `./.devcontainer/devcontainer.env`. Within this file you'll need to add the public key for each of the variables contained therein. The public key here should _omit_ the PEM headers/footers and should be on a single line. Adhere precisely to the naming convention already established inside. Remember there can be no blank spaces to either side of the = signs in this file.

**Do the above before beginning work in this repository.**

### Dev Container
This Terraform repository is meant to be run inside a VSCode Dev Container. Ensure that you have the 'Dev Containers' extension from Microsoft installed in VSCode before opening the repository.

If you have the extension installed correctly, when you open this repository you should get a pop-up on the bottom-right indicating that this repository has a Dev Container and asking if you'd like to use it. Choose 'Yes'.

It will take some time to build the Dev Container the first time. Once done you'll be in an independent environment with Terraform installed.

Verify things are working by running `terraform init` in the VSCode terminal.

## Structure
- **Root module** - Main Terraform configuration that orchestrates all modules.
- **modules/account_role_to_user** - Assigns roles to users.
- **modules/ownership_to_role** - Assign ownership to roles.
- **modules/privilege_to_role** - Assigns privileges to roles. By far, the most complex module.
- **modules/roles** - Creates and manages Snowflake roles.
- **modules/users** - Creates and manages Snowflake service users.
- **modules/warehouses** - Creates and manages Snowflake compute warehouses.

## Style & Standards
All names in Snowflake should be entirely upper case.

### ELT & Transformation Processes
No ELT (extract, load, transform) processes should "reside inside" Snowflake. This means we should not be orchestrating data transformation with Snowflake notebooks, tasks, or dynamic tables. **All data transformation should be handled by dbt.**

### Roles
Broadly there should be four _types_ of roles within our Snowflake instance:
- **Oranization role**... roles. For example, "DEVELOPER", "ANALYST", "BUSINESS ANALYST." These establish "breadth" or "domain" access within the data. For example, ensuring that developers can access raw data or that marketing users can only access marketing data.
- **Band role**: These would be roles like "INDIVIDUAL CONTRIBUTOR", "MANAGER", "EXECUTIVE." These establish "vertical" access to data. For example, in the future it may be desirable to ensure that only executives have access to realtime company financial data.
- **Service role**: Roles that enable different platforms and services to access our data for the purposes of loading their own data, extracting data for their use, or transforming our internal data.
- **Security role**: Roles that restrict access to privileged information. For example, a "PII_ACCESS" role to limit access to PII to only those users and services for which it is critical.

**Organization** and **Band** roles should be loosely coupled to the official record of the organization. For example, "DEVELOPER" is a formal job title within the organization. This establishes the type of work a user might be doing. And, in the future, it can be combined with a Band role to establish the breadth of the data those in that role can access. In the future this will hold true for Band roles as well, they should be named roughly according to the bands that exist in the official Org Chart. For example, "MANAGER" is a title that can be held and denotes band.

**Service** roles should be named according to the service utilizing them and the environment they operate in. For example, "FIVETRAN_PROD" indicates the Fivetran service and that it is operating on production data. If a service _only_ operates on one kind of data, it should be suffixed with "_PROD".

All **role** names should be **singular** to align with actual job titles/roles. For example, "ANALYST" not "ANALYSTS" because the matching job title would be "Analyst," we wouldn't hire an individual to be an "Analysts."

### Warehouses
Every **service** that connects to Snowflake should have a dedicated warehouse to facilitate cost monitoring. Likewise, every **organizational** role should have a dedicated warehouse to monitor costs and to mitigate collisions in query execution.

Warehouses should be named according to the **service** or **organizational** role that primarily operates that warehouse and suffixed with "_WH". For example, "FIVETRAN_WH" or "ANALYST_WH". In the event that a service requires multiple warehouses of different size, the size should be included in the name. For example, "FIVETRAN_XS_WH".

All warehouses should be created as Extra Small (XS) in the beginning and only scaled up if usage warrants.

## Terraform Configuration
### Variables
Main connection variables defined in `variables.tf`:

**Connection:**
- `snowflake_account` - Snowflake account identifier
- `snowflake_organization` - Snowflake organization name
- `snowflake_user` - Snowflake service user for authentication (default: "TERRAFORM_SVC")

**Account Role to User Module:**
- `role_roles` - Map of account roles to their parent roles (enables role hierarchy)
- `user_roles` - Map of users to a list of their assigned roles

**Ownership to Role Module:**
- `database_ownership` - Ownership grants on all/future objects within databases (key = database name, value = map of role -> list of object types)
- `schema_ownership` - Ownership grants on all/future objects within schemas (key = DB.SCHEMA, value = map of role -> list of object types)
- `object_ownership` - Ownership grants on specific objects (key = object type, value = map of object name -> role)

**Privilege to Role Module:**
- `database_privileges` - Database-level privileges organized by database name, including direct database privileges, schema privileges, and object privileges
- `schema_privileges` - Schema-specific privileges for when different privileges are needed per schema (key format: DATABASE.SCHEMA)
- `table_privileges` - Individual table-level privileges with optional exclusion from bulk grants (key format: DATABASE.SCHEMA.TABLE)
- `view_privileges` - Individual view-level privileges with optional exclusion from bulk grants (key format: DATABASE.SCHEMA.VIEW)
- `account_object_privileges` - Account-level object privileges for warehouses, integrations, etc.
- `account_privileges` - Account-level privileges (e.g., CREATE DATABASE, MANAGE GRANTS)

**Roles Module:**
- `roles` - List of roles to create and maintain (name, optional comment)

### Providers
The connection to Snowflake makes use of three providers defined in `./main.tf`: `sf-sysadmin`, `sf-securityadmin`, and `sf-useradmin`. These providers use dedicated Terraform roles (`SYSADMIN_TF`, `SECURITYADMIN_TF`, `USERADMIN_TF`) assigned to the TERRAFORM_SVC user to perform tasks.

Generally speaking, `sf-sysadmin` should be used for managing the data infrastructure of Snowflake. Generally, this is limited to the creation and management of compute warehouses. However, this could potentially expand to the creation and management of things like databases, schemas, file formats etc.

The `sf-securityadmin` provider is for managing roles, the privileges assigned to roles, and the roles assigned to users. Note, however, that this role should not be used for the actual creation and management of users as that responsibility should primarily reside with IT/Security.

The `sf-useradmin` provider is specifically for the creation and management of service user accounts. This should not be used to create or manage user accounts for humans, that process should be handled by IT/Security.

## Modules
### Account Role to User
Configuring role assignments to users and role hierarchies is done in the `./terraform.tfvars` file.

The map `role_roles` defines the role hierarchy, where each key is a child role and the value is a list of parent roles that should be granted to it. This enables role inheritance (e.g., ANALYST inherits privileges from DBT_DEV).

The map `user_roles` contains keys of user names accompanied by a list of roles that should be assigned to that user.

The user names and the list of roles to be applied should both be sorted alphabetically.

Service accounts should _only_ be granted their accompanying role(s). If a particular service has dedicated roles for production, development, staging, etc. environments, then a service account may have more than one role. We should not create a dedicated service account for each environment; rather, data access should be governed by the roles.

Human users should be given as few role assignments as possible. Aside from Snowflake administrators, there shouldn't be much reason for a human to have more than one **organizational** role, one **band** role, and some **security** roles. If you find yourself assigning a single user multiple organizational or band roles, this likely indicates that these roles or their granted privileges are not optimal.

Update role assignments to users by running: `terraform plan -target=module.account_role_to_user`. Verify that the changes Terraform is seeking to make align with your expectations. If everything looks correct, apply changes by running `terraform apply -target=module.account_role_to_user`.

### Ownership to Role
This module is similar to the '[Privilege to Role](#privilege-to-role)' module but this module only assigns ownership utilizing the "ownership" Terraform resource blocks.

Ownership is assigned using variables in `./terraform.tfvars`. Specifically:
- `database_ownership` - Ownership grants on all/future objects within databases
- `schema_ownership` - Ownership grants on all/future objects within specific schemas
- `object_ownership` - Ownership grants on specific objects (databases, schemas)

These variables use nested map structures that map databases/schemas to roles and their owned object types.

Update ownership assignments to roles by running: `terraform plan -target=module.ownership_to_role`. Verify that the changes Terraform is seeking to make align with your expectations. If everything looks correct, apply changes by running `terraform apply -target=module.ownership_to_role`.

### Privilege to Role
This is, by far, the most complex module in the repository. Privilege assignments to roles are controlled by structured variables defined in `./terraform.tfvars`. Specifically:
- `database_privileges` - Database-level privileges including direct database access, schema privileges, and object privileges for all/future objects
- `schema_privileges` - Schema-specific privileges when different from database-level defaults
- `table_privileges` - Individual table-level privileges with optional bulk grant exclusion
- `view_privileges` - Individual view-level privileges with optional bulk grant exclusion
- `account_object_privileges` - Privileges on account-level objects (warehouses, integrations)
- `account_privileges` - Account-level privileges (CREATE DATABASE, MANAGE GRANTS, etc.)

These variables use nested map structures organized hierarchically by database/schema/object, making it easier to understand and maintain privilege assignments.

Update privilege assignments to roles by running: `terraform plan -target=module.privilege_to_role`. Verify that the changes Terraform is seeking to make align with your expectations. If everything looks correct, apply changes by running `terraform apply -target=module.privilege_to_role`.

### Roles
The roles module is controlled by the variable `roles` defined in `./terraform.tfvars`. This is an array/list of objects that contain the role name and an optional comment describing the role's function. All roles should be accompanied by a comment that describes the role's use and, if applicable, who is responsible for it.

Conventions for the types of roles that should exist and how they should be named are outlined above in the [Style & Standards](#style--standards) section.

Update existing roles or create new ones by running: `terraform plan -target=module.roles`. Verify that the changes Terraform is seeking to make align with your expectations. If everything looks correct, apply changes by running `terraform apply -target=module.roles`.

### Users
The users module manages Snowflake service user accounts. Existing service users are managed directly in `./modules/users/main.tf` as `snowflake_legacy_service_user` resources. **New** service users should be defined using the `snowflake_service_user` resource block. Each service user resource includes:
- User name and login credentials.
- Display name, email, and optional comments.
- Default role and warehouse assignments.

Service users are typically created for third-party integrations (e.g., Fivetran, dbt, Segment) and internal ELT pipelines. The service user accounts do not require SSO integration, unlike human users which are managed separately by IT/Security.

Update service users by running: `terraform plan -target=module.users`. Verify that the changes Terraform is seeking to make align with your expectations. If everything looks correct, apply changes by running: `terraform apply -target=module.users`.

The users module utilizes the `sf-useradmin` provider to ensure proper permissions for user account creation and management.

### Warehouses
The warehouses module is also not fed by input variables from `./terraform.tfvars`. The inputs to the warehouses module are so few and the accompanying parameters so dense that Ben felt it was easier to just manually define the warehouse resources in `./modules/warehouses/main.tf`. Adding new warehouses should follow the existing pattern defined therein.

Standards for which types of warehouses should be created and how they should be named can be found above in the [Style & Standards](#style--standards) section.

Update existing warehouses by running: `terraform plan -target=module.warehouses`. Verify that the changes Terraform is seeking to make align with your expectations. If everything looks correct, apply changes by running `terraform apply -target=module.warehouses`.
