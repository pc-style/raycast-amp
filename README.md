# Amp for Raycast

Start, find, steer, and watch [Amp](https://ampcode.com) threads without leaving Raycast.

| Command | What it does |
| --- | --- |
| **New Thread** | Form with prompt, project, mode, title, orb size, and Fast. Starts an orb thread, copies its URL, and opens it. |
| **Start Thread** | Same from the root search: `Start Thread <prompt> [project]`. Uses your default project and mode. |
| **Search Threads** | Amp's query syntax (`repo:`, `author:`, `after:7d`, `pr:`), quick filters, and per-project filters. Threads working right now are pinned on top and update live. Actions: open, send a message, read the transcript, copy URL / `@T-…` mention / `amp threads continue` command, rename, archive. |
| **Thread Activity** (menu bar) | Inbox of threads that finished since you last opened them, plus a HUD when a thread you saw working finishes. |
| **Currently Running** (menu bar) | Count of agents working right now, grouped by project. |
| **Ask Puck** | Chat with Puck. Type in the search bar and press Enter; continues your latest Puck conversation (⌘N for a new one). |
| **Call Puck** | Runs the Amp Mac app's *Call Puck* shortcut. |
| **Search Projects** | Your Amp projects; start a thread in one or list its threads. |
| **Open Portal** | Portals of your running orbs. |

## Setup

The extension drives the [Amp CLI](https://ampcode.com/install), so install it and run `amp login` once. If the CLI lives somewhere unusual, set **Amp CLI Path**; if you'd rather not sign the CLI in, paste an access token from ampcode.com/settings/security into **Access Token**.

Set **Open Threads In** to *Amp for Mac* to open links in the Mac app instead of the browser.

## How it works

Everything goes through public CLI commands: `threads list/search/export/markdown/rename/archive`, `projects list`, `--execute --orb-execute` to start and message threads, and `top --stream-jsonl` for live working state.

- **Puck** conversations are ordinary threads in `puck` mode, so Ask Puck sends with `threads continue` and waits for the reply, using `amp top` to know when Puck stops working.
- **Portals** have no CLI listing. Portal hosts embed the thread UUID in base36 (`t-<uuid36>-p<port>.onamp.dev`), so Open Portal reads the transcripts of threads whose orbs are connected and picks out URLs on their own hosts. Portals an agent never printed, and custom portal hostnames, won't appear.

## Development

```sh
npm install
npm run dev     # ray develop
npm run lint
npm run build
```
