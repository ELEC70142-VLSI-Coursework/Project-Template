# Continuous integration for your project

This is a recommendation, not a requirement. It sets up GitHub Actions so that every push to your repository is checked automatically and the whole flow runs every night on the teaching server, with the results waiting for you in the morning.

## Why

- A change that breaks synthesis, timing or equivalence is found the day it is made, not the week before tapeout.
- The full flow takes over an hour. Run nightly, it costs nobody's time and the trend of slack, coverage and DRC counts tells you more than any single run.

## How it works

A workflow is a file in `.github/workflows/`. GitHub runs its jobs on a machine of your choosing whenever the trigger in the file fires: a push, a pull request, a timer, or a button on the Actions tab. A step fails when its command returns a non-zero exit code, and the job stops there.

Two kinds of machine:

- **GitHub's own**, `runs-on: ubuntu-latest`. A fresh virtual machine, thrown away after the job, with no EDA tools and never any. Fine for anything tool-free: linting, a Verilator simulation, a check that the repository has what it should.
- **A self-hosted runner**, a small agent you install on your teaching server. Fusion Compiler, the PDK and the licences never leave the department network, so this is the only place your flow can run. The runner makes an outbound connection to GitHub and holds it open waiting for work; nothing connects inbound to the server, which is why it works from behind the College firewall.

`docs/ci/` holds two workflow templates for the self-hosted runner and the script they depend on:

| File | Trigger | For | Time |
|---|---|---|---|
| `docs/ci/checks.yml` | every push and pull request to `main` | checks that finish in minutes | minutes |
| `docs/ci/nightly.yml` | every night, and the Actions tab | the whole flow, results kept on the server | hours |
| `docs/ci/eda_run` | every tool step of both | one command inside the Synopsys environment, from a bash step | |

To adopt them, copy `eda_run` to `scripts/` and the two workflows to `.github/workflows/`, then fill in the places marked `TODO`: the runner label, the tools directory, and the steps themselves. The templates run nothing of the flow; what goes in them is your choice. For the push checks, `make synth` alone is a good start, `make dft` and `make lec` after it if there is time; for the nightly, one step per stage through `make fusion` and `make lec_chip`, so that a failure names the stage.

Both must pass or fail on the reports, not on the tools' exit codes: Fusion Compiler exits 0 with a log full of errors, so a job that only ran the commands would always be green. The `Did it actually work` step exists for that, and the nightly template fails there until you write it: a negative slack in `reports/finish_qor.rpt`, a routing violation count in `reports/route_check_repaired.rpt`, shorts or opens in `reports/finish_lvs.rpt`, and anything but `Verification SUCCEEDED` in the Formality logs are the obvious tests.

## Setting up on GitHub

1. In your repository go to **Settings > Actions > Runners > New self-hosted runner** and choose Linux. GitHub shows the download and configure commands.
2. Give the runner a label of your own when `config.sh` asks, or with `--labels ee-mill2,team-07`. Several teams share each server; without your own label, your jobs can be picked up by another team's runner and theirs by yours.
3. Copy `docs/ci/eda_run` to `scripts/` and the two workflows to `.github/workflows/`, and edit their `TODO` lines: the label, the path of the tools directory holding `setup.cshrc`, and the directory holding your memory compiler outputs.

## Setting up on the server

1. Run the commands GitHub gave you in a directory of their own, `~/actions-runner`. You have no root on the teaching servers, so the runner cannot be installed as a service; run it in a terminal multiplexer so that it survives you logging out:

```bash
tmux new -s runner
cd ~/actions-runner && ./run.sh
# Ctrl-b then d to detach; tmux attach -t runner to come back
```

The runner shows as **Idle** on the Runners page.

2. The runner starts a plain bash shell that sources none of your login files, and the Synopsys environment is built in tcsh, so a step cannot simply source `setup.cshrc`. `scripts/eda_run` bridges the two: it starts a tcsh, sources `setup.cshrc` non-interactively, checks that the environment loaded, and runs the command it was given. Every tool step in the workflows goes through it. `vlsi-tooling/syn` cannot be used here, it ends in an interactive shell that would hang the job until it times out.

3. If your design uses compiled memories, keep their compiler outputs in a directory on the server. As the README says, they are not in the repository, and a job's checkout is cleaned on every run, so the `Vendor views` step of each template links them in each time. Without memories, delete that step.

4. Push a change and open the Actions tab. If a job sits on **Queued** and never starts, the label in the workflow matches no runner; there is no error message for this, so check the spelling against the Runners page.

## Sharing the server

The server is shared with every other team.

- **Know what you are running.** `ps -u $USER -o pid,rss,etime,comm --sort=-rss | head` lists your processes, heaviest first. A crashed `fc_shell` or a forgotten Verdi holds gigabytes for days; kill your own strays.
- **Watch your home directory.** Every job checks the repository out again and every nightly run leaves a layout behind. The nightly workflow keeps the last seven runs and prunes the rest; `du -xh --max-depth=1 $HOME | sort -h | tail` shows what is filling the disk.
- **Stagger your nightly.** If every team schedules 02:00, you have built a queue.
- **Stop the runner** when the project is over and remove `~/actions-runner`.
- **Never commit PDK content.** Library files, technology files, GDS and memory compiler outputs are covered by the TSMC NDA. The template's `.gitignore` covers the tool outputs, the runner's files and the vendor views; keep the repository private.
