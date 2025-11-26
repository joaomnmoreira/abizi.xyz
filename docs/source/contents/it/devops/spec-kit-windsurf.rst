GitHub Spec Kit + Windsurf
================================

This guide shows how to use `Windsurf <https://windsurf.com/editor>`_
with `GitHub's spec-kit <https://github.com/github/spec-kit>`_ to implement a
Spec-Driven Development workflow in your repositories.

Overview
--------

- Windsurf provides an agentic coding assistant that can plan, edit files,
  run commands, and create pull requests from your IDE or terminal.
- GitHub's spec-kit bootstraps a "spec-first" workflow. You describe a feature
  in plain language; spec-kit generates a structured specification and a
  repository scaffold the agent can implement against.

Typical flow
~~~~~~~~~~~~

1. Create or open a repository for your feature/product.
2. Initialize spec-kit to generate a spec and structure.
3. Use Windsurf to plan and implement against the generated spec.
4. Iterate on the spec and code via small, reviewable changes (PRs).

Prerequisites
-------------

- Git installed and authenticated to GitHub
- ``uv`` (Astral) if you want to run spec-kit via ``uvx``; otherwise use the
  clone-and-run alternative below. See installation steps in the next section.
- A GitHub repository (local clone) to work in

Install Windsurf
-------------------------

Follow the official installation guide:
https://docs.windsurf.com/windsurf/getting-started


Install uv (required for ``uvx``)
---------------------------------

`uv <https://docs.astral.sh/uv/>`_ is a fast Python packaging tool from Astral.
It provides the ``uvx`` runner we use to execute spec-kit directly from Git.

Follow the official installation guide:
https://docs.astral.sh/uv/getting-started/installation/

On Linux/macOS, a quick install is:

.. code-block:: bash

   curl -LsSf https://astral.sh/uv/install.sh | sh

After installation, restart your shell or ensure that the installer updated your
``PATH``. Verify it with:

.. code-block:: bash

   uv --version
   uvx --version

Install spec-kit
----------------

spec-kit offers a CLI you can run directly via ``uvx`` or install locally.
The ``uvx`` approach avoids a local install and fetches from Git on demand.

.. code-block:: bash

   # Using uvx (recommended if you have uv installed)
   # Replace <PROJECT_NAME> with your repo or feature name
   uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>

If you do not use ``uvx``, clone the repository and follow its README.

.. code-block:: bash

   # Alternative: clone and run locally
   git clone https://github.com/github/spec-kit.git
   cd spec-kit
   # See README for local invocation options

Initialize a repository with spec-kit
-------------------------------------

From the root of your target repository (or a fresh directory):

.. code-block:: bash

   # 1) Initialize spec-driven scaffolding and spec documents
   uvx --from git+https://github.com/github/spec-kit.git \
       specify init my-awesome-service

   # 2) Review what was created
   git status

   # 3) Commit the generated spec and scaffolding
   git add .
   git commit -m "chore(spec): initialize spec-kit scaffolding"

You should see a structured specification and supporting files added to your
repo. Inspect and edit the spec to reflect the real requirements.

Kick off development with Windsurf
-------------------------------------

1. In Spec-kit 'Choose your AI assistant:' prompt, select Windsurf.
2. In 'Choose script type:' prompt, select 'sh'.

Next steps:
-----------

1. Go to the project folder: cd <Project  Name>
2. Start using slash commands with your AI agent:
   2.1 /speckit.constitution - Establish project principles
   2.2 /speckit.specify - Create baseline specification
   /speckit.clarify (optional) - Ask structured questions to de-risk ambiguous areas before planning (run before /speckit.plan if used)
   
   2.3 /speckit.plan - Create implementation plan
   /speckit.checklist (optional) - Generate quality checklists to validate requirements completeness, clarity, and consistency (after /speckit.plan)
   2.4 /speckit.tasks - Generate actionable tasks
   /speckit.analyze (optional) - Cross-artifact consistency & alignment report (after /speckit.tasks, before /speckit.implement)
   2.5 /speckit.implement - Execute implementation

Optional commands that you can use for your specs (improve quality & confidence):

   ○ 
   ○ 
   ○ 

Detailed process
----------------

The steps below summarize the official spec-kit workflow and example prompts.

STEP 1: Bootstrap the project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- In your project folder, open Windsurf.

1. Establish project principles
   Use the ``/speckit.constitution`` command to create principles focused on code quality, testing standards, user experience consistency, and performance requirements

2. Create the spec
   Use the ``/specify`` command to describe what you want to build. Focus on the
   what and why, not the tech stack.

.. code-block:: text

   /specify Build an application that can help me organize my photos in separate
   photo albums. Albums are grouped by date and can be re-organized by dragging
   and dropping on the main page. Albums are never in other nested albums. Within
   each album, photos are previewed in a tile-like interface.

3. Create a technical implementation plan
   Use the ``/plan`` command to provide your tech stack and architecture choices.

.. code-block:: text

   /plan The application uses Vite with minimal number of libraries. Use vanilla
   HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere
   and metadata is stored in a local SQLite database.

4. Break down and implement
   Use ``/tasks`` to create an actionable task list, then ask your agent to
   implement the feature.

After this, Claude Code should create a new branch (e.g., ``001-create-taskify``)
and generate a spec in ``specs/001-create-taskify/spec.md`` along with templates.

.. important::

   Be as explicit as possible about what you are trying to build and why.
   Do not focus on the tech stack at this point.

Example prompt (Taskify, from README):

.. code-block:: text

   Develop Taskify, a team productivity platform. It should allow users to create
   projects, add team members, assign tasks, comment and move tasks between boards
   in Kanban style. In this initial phase for this feature, let's call it "Create
   Taskify," let's have multiple users but the users will be declared ahead of time,
   predefined. I want five users in two different categories, one product manager
   and four engineers. Let's create three different sample projects. Let's have the
   standard Kanban columns for the status of each task, such as "To Do," "In Progress,"
   "In Review," and "Done." There will be no login for this application as this is just
   the very first testing thing to ensure that our basic features are set up. For each
   task in the UI for a task card, you should be able to change the current status of
   the task between the different columns in the Kanban work board. You should be able
   to leave an unlimited number of comments for a particular card. You should be able to,
   from that task card, assign one of the valid users. When you first launch Taskify, it's
   going to give you a list of the five users to pick from. There will be no password
   required. When you click on a user, you go into the main view, which displays the list of
   projects. When you click on a project, you open the Kanban board for that project. You're
   going to see the columns. You'll be able to drag and drop cards back and forth between
   different columns. You will see any cards that are assigned to you, the currently logged
   in user, in a different color from all the other ones, so you can quickly see yours. You
   can edit any comments that you make, but you can't edit comments that other people made.
   You can delete any comments that you made, but you can't delete comments anybody else made.

After entering this prompt, Claude Code should kick off planning and spec drafting,
and trigger built-in scripts to set up the repository.

Initial project contents after bootstrapping (example):

.. code-block:: text

   ├── memory
   │\t ├── constitution.md
   │\t └── constitution_update_checklist.md
   ├── scripts
   │\t ├── check-task-prerequisites.sh
   │\t ├── common.sh
   │\t ├── create-new-feature.sh
   │\t ├── get-feature-paths.sh
   │\t ├── setup-plan.sh
   │\t └── update-claude-md.sh
   ├── specs
   │\t └── 001-create-taskify
   │\t     └── spec.md
   └── templates
       ├── plan-template.md
       ├── spec-template.md
       └── tasks-template.md

STEP 2: Clarify the functional specification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Refine the generated spec and explicitly check the Review & Acceptance Checklist.

Prompts you can use:

.. code-block:: text

   In this project there should be a variable number of tasks between 5 and 15
   tasks for each one randomly distributed into different states of completion. Make sure that there's at least
   one task in each stage of completion.

   1. Task format: TodoWrite tasks
   2. Completion states: With specific states, pending, in_progress, completed
   3. Project context: Current Brand Detection Microservice
   5. Output format: As files and todo lists

.. code-block:: text

   Read the review and acceptance checklist, and check off each item if the
   feature spec meets the criteria. Leave it empty if it does not.

STEP 3: Generate a technical plan
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now specify the tech stack and generate an implementation plan using ``/plan``.

Example prompt (from README):

.. code-block:: text

   We are going to generate this using .NET Aspire, using Postgres as the database.
   The frontend should use Blazor Server with drag-and-drop task boards and real-time
   updates. There should be a REST API (projects, tasks, notifications).

This step produces implementation detail documents under the corresponding
``specs/<feature>/`` directory (e.g., ``plan.md``, ``data-model.md``,
``contracts/api-spec.json``, ``research.md``, etc.). Review and refine ``research.md``
to ensure versions and components are correct.

Additionally, you might want to ask Claude Code to research details about the
chosen tech stack if it's something that is rapidly changing (e.g., .NET Aspire,
JS frameworks), with a prompt like this:

.. code-block:: text

   I want you to go through the implementation plan and implementation details, looking for areas that could
   benefit from additional research as this stack is a rapidly changing library. For those areas that you identify that
   require further research, I want you to update the research document with additional details about the specific
   versions that we are going to be using in this Taskify application and spawn parallel research tasks to clarify
   any details using research from the web.

During this process, you might find that Claude Code gets stuck researching the wrong
thing — you can help nudge it in the right direction with a prompt like this:

.. code-block:: text

   I think we need to break this down into a series of steps. First, identify a list of tasks
   that you would need to do during implementation that you're not sure of or would benefit
   from further research. Write down a list of those tasks. And then for each one of these tasks,
   I want you to spin up a separate research task so that the net results is we are researching
   all of those very specific tasks in parallel. What I saw you doing was it looks like you were
   researching .NET Aspire in general and I don't think that's gonna do much for us in this case.
   That's way too untargeted research. The research needs to help you solve a specific targeted question.

STEP 4: Validate the plan with Claude Code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Have Claude Code audit the plan for gaps and sequencing:

.. code-block:: text

   Now I want you to go and audit the implementation plan and the implementation detail files.
   Read through it with an eye on determining whether or not there is a sequence of tasks that you need
   to be doing that are obvious from reading this. Because I don't know if there's enough here. For example,
   when I look at the core implementation, it would be useful to reference the appropriate places in the implementation
   details where it can find the information as it walks through each step in the core implementation or in the refinement.

Optionally, ask Claude Code to open a pull request for the planning work if you use
the GitHub CLI. Also ask it to identify and resolve any over-engineering.

.. note::

   Before implementation, cross-check details for potential over-engineering. If it added components you did not ask for,
   have it clarify the rationale and resolve them. Ensure it follows the project constitution.

STEP 5: Implementation
~~~~~~~~~~~~~~~~~~~~~~

Once validated, instruct Claude Code to implement against the plan:

.. code-block:: text

   implement specs/002-create-taskify/plan.md

Claude Code will make changes, run commands, and iterate. Ensure required local
CLIs and runtimes are installed (e.g., ``dotnet`` if applicable). Ask Claude Code
to build/run and address compile-time or runtime errors as they appear.

Best practices
--------------

- Keep specs authoritative. Update the spec when scope changes, then code.
- Prefer small, iterative PRs. Claude Code can help open and update them.
- Enforce style, linting, and tests in CI to maintain quality.
- Store prompts and decisions in the repo (docs/) for future maintainers.

References
----------

- Anthropic Claude Code: https://www.anthropic.com/claude-code
- Claude Code docs: https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview
- GitHub spec-kit: https://github.com/github/spec-kit
- Spec-Driven Development guide (spec-kit): https://github.com/github/spec-kit/blob/main/spec-driven.md
