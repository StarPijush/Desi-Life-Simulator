# Event Coverage Report

Generated audit target: zero player-facing generic popup fallbacks.

## Coverage Matrix

| System | Offer Events | Requirement Events | Success Events | Failure Events |
| --- | --- | --- | --- | --- |
| Career | Career opening, job offer | Role lock, education/smarts gates | Hired, career switch, structured promotion | Interview failed, unavailable role |
| Military | Enlistment offer | Age, education, smarts enlistment gates | Enlisted, training, mission success, structured promotion | Injury, mission failure, training failure |
| Politics | Join party, campaign launch | Campaign funds, party influence, experience gates | Join Party, Election Debate, Election Victory, Cabinet Appointment, Prime Minister Election | Election Defeat, Political Scandal, party setbacks |
| Influencer | Sponsorship offer, platform start | Age, education, social, follower gates | Viral Video, verification, sponsorship signed | Verification rejected, weak engagement outcomes |
| Freelance | Gig/project offer | Smarts and effort gates | Project payout, client growth | Client loss, burnout, weak delivery |
| Education | Course/exam offer | Age, education level, score gates | Exam pass, enrollment, graduation | Exam fail, ineligible enrollment |
| Scholarship | Scholarship offer | Marks, smarts, education gates | Scholarship Award | Scholarship rejected |

## Structured Event Inventory

| Event Kind | Factory/API |
| --- | --- |
| Promotion Events | `EventFactory.promotion` |
| Raise Events | `EventFactory.raiseReceived` |
| Termination Events | `EventFactory.fired` |
| Resignation Events | `EventFactory.resignation` |
| Military Mission Events | `EventFactory.missionSuccess`, `EventFactory.missionFailure` |
| Military Medal Events | `EventFactory.militaryAward` |
| Deployment Events | `EventFactory.deploymentOrders` |
| Military Retirement Events | `EventFactory.militaryRetirement` |
| Scholarship Events | `EventFactory.scholarshipAward`, `EventFactory.scholarshipRejected` |
| Education Milestones | `EventFactory.examResult`, `EventFactory.graduation`, `EventFactory.universityAdmission` |
| Politics Events | `EventFactory.joinParty`, `EventFactory.electionVictory`, `EventFactory.electionDefeat`, `EventFactory.politicalScandal`, `EventFactory.cabinetAppointment` |
| Influencer Events | `EventFactory.channelCreated`, `EventFactory.viralVideo`, `EventFactory.verificationApproved`, `EventFactory.verificationRejected`, `EventFactory.sponsorshipOffer` |
| Freelance Events | `EventFactory.projectOffer`, `EventFactory.projectCompletion`, `EventFactory.clientComplaint`, `EventFactory.bonusPayment` |
| Failure Events | `EventFactory.failure`, `EventFactory.politics(... failure)`, `EventFactory.militaryInjury` |
| Requirement Events | `EventFactory.requirements`, `EventFactory.requirement` |
| Offer Events | `EventFactory.offer` |

## Final Audit

| Metric | Count |
| --- | ---: |
| Total Structured Events | 343 |
| Premium Phase 2 Events Count | 170 |
| Legendary Events Count | 48 |
| Epic Events Count | 103 |
| Good Events Count | 343 |
| Generic Events Count | 0 |

Missing Premium Events: None for the requested event families.

Phase 2 premium expansion includes military, politics, influencer, business,
relationship, family, health, science, sports, fame, and career-defining legacy
events. Legendary events use the shared premium builder weight of `0.4`, keeping
them extremely rare while still allowing life-changing outcomes.

### Events by Category

| Category | Count |
| --- | ---: |
| Business | 37 |
| Career | 17 |
| Crime | 10 |
| Education | 15 |
| Fame | 2 |
| Family | 30 |
| Freelance | 11 |
| Health | 30 |
| Influencer | 36 |
| Military | 46 |
| Politics | 38 |
| Relationship | 10 |
| Relationships | 20 |
| Scholarship | 15 |
| Science | 2 |
| Sports | 24 |

### Events by Rarity

| Rarity | Count |
| --- | ---: |
| Common | 25 |
| Uncommon | 49 |
| Rare | 118 |
| Epic | 103 |
| Legendary | 48 |

Missing Requirement Data: No factory-generated requirement event is missing structured requirement metadata. Some legacy screen-level dialogs still render direct `showEventCard` requirements and should be migrated to `EventFactory.requirements` when those screens are next touched.

Missing Offer Data: No factory-generated offer event is missing structured offer metadata. Legacy screen-level offer dialogs have partial rows; military enlistment now includes rank, salary, hours, risk, and reward.

## Generic Fallback Audit

Message-only `ActionResult` values now become timeline updates through
`EventFactory.genericTimelineOnly`. These events are marked with
`popupAllowed: false` and `genericFallback: true`, so `EventCard` never turns
message text into player-facing popup content.

Current player-facing generic popup fallback count: 0.

## Generic Title Ban

The following titles are banned for player-facing popups:

- Action Complete
- Action Failed
- Success
- Failure
- Operation Successful
- Completed Successfully

Allowed usage: debug logs, developer tooling, and non-popup timeline safety text.
