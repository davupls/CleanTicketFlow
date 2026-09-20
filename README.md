# Clean Ticket Flow

**An ATM maintenance ticketing app for iOS.** Three user roles (bank custodian, dispatcher, field technician) work from one shared database as a single source of truth, following a ticket from first report to resolution.

<p align="center">
  <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/03-custodian-report-issue-form.png" width="200" alt="Custodian reporting an ATM issue">
  <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/09-dispatcher-assign-technician.png" width="200" alt="Dispatcher assigning a technician">
  <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/15-technician-ticket-part-used-mark-resolved.png" width="200" alt="Technician resolving a ticket">
</p>

## What the App Does

Clean Ticket Flow lets bank **custodians** report ATM problems and follow their tickets. **Dispatch** then triages and assigns the work, and **technicians** carry it out in the field. Each role signs in with its own credentials and sees only the tools it needs.

### Custodian: report and track
- Report an issue by choosing the ATM, issue type, priority (Low to Critical) and a description
- Track open and resolved tickets, with a progress bar: Submitted → Assigned → In progress → Resolved
- View every ATM at the branch and its current status

| Sign in | Branch home | Report an issue | My Tickets |
|:---:|:---:|:---:|:---:|
| <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/01-sign-in.png" width="170"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/02-custodian-home-atm-list.png" width="170"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/03-custodian-report-issue-form.png" width="170"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/04-custodian-my-tickets-open.png" width="170"> |

### Dispatch: assign and oversee
- Assign tickets to technicians, with techs sorted by zone proximity and availability
- Cancel tickets that aren't covered by the company
- See field activity at a glance: who is on shift, busy or available
- Watch SLA countdowns on every ticket in the queue
- Generate SLA reports: compliance by month, average resolution time, tickets by issue type

| Dispatch queue | Assign technician | Technicians | SLA reports |
|:---:|:---:|:---:|:---:|
| <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/06-dispatcher-queue.png" width="170"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/09-dispatcher-assign-technician.png" width="170"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/07-dispatcher-technicians.png" width="170"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/08-dispatcher-reports.png" width="170"> |

### Technician: work the ticket
- View tickets assigned by dispatch, sorted by SLA deadline
- Open a ticket for ATM details, model, location and service history
- Tap **Directions** to open a maps app with the location pre-loaded
- Move a ticket through **En Route → On Site → Marked Resolved**
- Add parts from van inventory and add notes to the ticket
- Check van inventory, with low-stock warnings and a restock request
- Review a history of completed tickets with average SLA resolution time

| My Tickets | Ticket detail | Parts and resolve | Van inventory | History |
|:---:|:---:|:---:|:---:|:---:|
| <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/11-technician-my-tickets.png" width="140"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/14-technician-ticket-detail-en-route.png" width="140"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/15-technician-ticket-part-used-mark-resolved.png" width="140"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/12-technician-van-inventory.png" width="140"> | <img src="CleanTicketFlow/CleanTicketFlow/Screenshots/17-technician-history-resolved.png" width="140"> |

### Built-in search
Search by ticket number, ATM ID or branch, for when things get busy.

## Tech Stack
- **Swift**
- **SwiftUI** for the interface
- **SwiftData** for persistence, shared across all roles
- **Swift Testing** (Apple's testing library)
- **Foundation**

## Roadmap

**Notifications** are not yet implemented. They would alert every role when a ticket's status changes. Technicians and dispatch are the top priority, since they need to know about changes as soon as possible.
