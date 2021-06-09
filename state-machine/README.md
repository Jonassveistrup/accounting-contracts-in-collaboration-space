# An XML representation of a scenario running on a DBTR

There are three XML vocabularies in play in this demonstration scenario recorded on video, each described by a constraining schema:
- a colloquial XML vocabulary describing the DBTR and its defined state machines
  - constrained by the [`dbtr.rnc`](dbtr.rnc) schema in RELAX-NG Compact Syntax
  - the DBTR used in the example scenario is [`dbtr-paper.xml`](dbtr-paper.xml)
  - this file is used in a Python application to synthesize the Solidity state machine representation
- a colloquial XML vocabulary describing the scenario's business events and their associated stimuli
  - constrained by the [`scenario.rnc`](scenario.rnc) schema in RELAX-NG Compact Syntax
  - the example scenario business events and stimuli are in [`scenario-paper.xml`](scenario-paper.xml)
  - this file is used to write, debug, and test the events, stimuli, and state machine transitions before creating the blockchain code
- the internationally-standardized OASIS Universal Business Language (UBL) Version 2.1 ISO/IEC 19845:2015
  - constrained by the W3C Schema expressions that are distributed as part of the package deliverables
    - Version 2.1: [`http://docs.oasis-open.org/ubl/UBL-2.1.html`](http://docs.oasis-open.org/ubl/UBL-2.1.html)
      - semantics: [`http://docs.oasis-open.org/ubl/os-UBL-2.1/mod/summary/reports/UBL-AllDocuments-2.1.html`](http://docs.oasis-open.org/ubl/os-UBL-2.1/mod/summary/reports/UBL-AllDocuments-2.1.html)
    - Version 2.3: [`http://docs.oasis-open.org/ubl/UBL-2.3.html`](http://docs.oasis-open.org/ubl/UBL-2.3.html)
      - semantics: [`http://docs.oasis-open.org/ubl/os-UBL-2.3/mod/summary/reports/All-UBL-2.3-Documents.html`](http://docs.oasis-open.org/ubl/os-UBL-2.3/mod/summary/reports/All-UBL-2.3-Documents.html)
  - this vocabulary is cited for each business event and is the putative interchange document from a user's environment, such as an ERP system, to this project's running production code as a supplement of the colloquial scenario XML that defines the stimuli associated with each document

## Artefacts supporting a scenario running on a DBTR

This directory contains the following artefacts documenting the running of a particular pre-payment purchasing scenario on an ISO/IEC 15944-21 Distributed Business Transaction Repository (DBTR) tracking an ISO/IEC 15944-4 Business Transaction:

- [`scenario-paper.pdf`](scenario-paper.pdf) (start here)
  - a human-oriented output rendering of the history of the states of each of the numerous instantiated and yet-to-be-instantiated state machines as they transition in response to stimuli associated with business events
- [`scenario-paper.xml`](scenario-paper.xml)
  - a machine-readable input coding of the scenario's business events and each of the DBTR stimuli and properties associated with the events
- [`dbtr-paper.xml`](dbtr-paper.xml)
  - a machine-readable input coding of all of the available state machines in the DBTR that may or may not be triggered by stimuli from a scenario of business events
- [`scenario.rnc`](scenario.rnc)
  - the XML document model schema constraining the expression of a scenario of multiple business events and their associated DBTR state machine stimuli
- [`dbtr.rnc`](dbtr.rnc)
  - the XML document model schema constraining the expression of all of a given DBTR's state machines and their associated state changes
- [`scenario-paper.dbtr-history.xml`](scenario-paper.dbtr-history.xml)
  - a machine-readable diagnostic review of the history of all of the DBTR transitions triggered by all of the scenario's business event stimuli
- [`scenario-paper-narration-video-cover-pages.pdf`](scenario-paper-narration-video-cover-pages.pdf)
  - the cover pages used in the narration video
- [`scenario-paper-narration-video-transcript.pdf`](scenario-paper-narration-video-transcript.pdf)
  - a complete transcript of the narration video
- [`AAA-SPARK-2020-06-McCarthy-keynote-slides-with-links.pdf`](AAA-SPARK-2020-06-McCarthy-keynote-slides-with-links.pdf)
  - excerpted slides with hyperlinks cited in the video

## Narration video of the state machine scenario PDF

An illustration of an ISO/IEC 15944-21 Open-edi* Distributed Business Transaction Repository (OeDBTR) immutable record of business transactions in accounting collaboration space

April 2021

A research collaboration led by Jonas Sveistrup Soegaard and William McCarthy with Lasse Herskind and G. Ken Holman

[`https://gkenholman.page.link/oedbtr-202104-pdf`](https://gkenholman.page.link/oedbtr-202104-pdf) - the example scenario PDF file

[`https://gkenholman.page.link/oedbtr-202104-video`](https://gkenholman.page.link/oedbtr-202104-video) - the narration video

[`https://gkenholman.page.link/oedbtr-202104-transcript`](https://gkenholman.page.link/oedbtr-202104-transcript) - the narration transcript

## Background video describing REA principles

In June 2020 Bill recorded an excellent American Accounting Association SPARK keynote video describing the history of the Resource Entity Agent (REA) model, its principles, and the overview relationship of OeDBTR directly to REA. This is an excellent introduction to REA that is geared to accountants.

[`https://gkenholman.page.link/rea-202006-video`](https://gkenholman.page.link/rea-202006-video) - the keynote video (50 minutes)

[`https://gkenholman.page.link/rea-202006-pdf`](https://gkenholman.page.link/rea-202006-pdf) - excerpted keynote slides with links
