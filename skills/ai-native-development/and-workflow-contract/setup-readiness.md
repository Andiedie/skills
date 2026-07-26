# Setup Readiness

Read this reference only when `setup-and` evaluates or repairs repository readiness.

AND is ready when all of these facts are proven:

- one Git remote identifies one GitHub repository with Issues available;
- the active queue labels exist: `needs-triage`, `needs-info`, `needs-pack`, and `ready-for-agent`;
- structural labels required by installed workflow features exist, including `parent-prd` and the Wayfinding labels;
- the authenticated actor can create, edit, comment on, label, close, and reopen issues, and can assign itself for investigation ownership;
- native parent/sub-issue and blocked-by relationships are readable and their required write capability is proven;
- the root repository instructions direct Agents to GitHub workflow state, `ask-andie`, the installed AND skills, and this contract;
- no effective repository instruction names another workflow-state source or relationship convention.

Missing labels are repairable setup gaps. An unavailable or unverified native capability keeps the repository unready.
