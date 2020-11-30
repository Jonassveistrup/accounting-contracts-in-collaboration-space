# Artefacts supporting a scenario running on a DBTR

This directory contains the following artefacts documenting the running of a particular pre-payment purchasing scenario on an ISO/IEC 15944-21 Distributed Business Transaction Repository (DBTR) tracking an ISO/IEC 15944-4 Business Transaction:

- `scenario-paper.pdf` (start here)
  - a human-oriented output rendering of the history of the states of each of the numerous instantiated and yet-to-be-instantiated state machines as they transition in response to stimuli associated with business events
- `scenario-paper.xml`
  - a machine-readable input coding of the scenario's business events and each of the DBTR stimuli and properties associated with the events
- `dbtr-paper.xml`
  - a machine-readable input coding of all of the available state machines in the DBTR that may or may not be triggered by stimuli from a scenario of business events
- `scenario.rnc`
  - the XML document model schema constraining the expression of a scenario of multiple business events and their associated DBTR state machine stimuli
- `dbtr.rnc`
  - the XML document model schema constraining the expression of all of a given DBTR's state machines and their associated state changes
- `scenario-paper.dbtr-history.xml`
  - a machine-readable diagnostic review of the history of all of the DBTR transitions triggered by all of the scenario's business event stimuli
