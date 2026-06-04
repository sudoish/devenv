function zw --description 'Open the Zed work project and start all dev servers (replaces `tm work`)'
    set -l state_dir $HOME/.local/state/zw
    set -l settings $HOME/.config/zed/settings.json
    # The Zed work project root(s). Edit here to split into multiple sidebar roots.
    set -l zed_paths $HOME/work

    # server table: name | cwd | command   (mirrors ~/.config/tmuxinator/work.yml:12-17)
    set -l servers \
        "numbox-api|$HOME/work/numbox|source .venv/bin/activate.fish && task start" \
        "numbox-celery|$HOME/work/numbox|source .venv/bin/activate.fish && task start-celery-mac-os-tahoe" \
        "numbox-web|$HOME/work/numbox-clients/packages/numbox-web|yarn start" \
        "numa-agents|$HOME/work/agents/numa-agents|source .venv/bin/activate.fish && task dev" \
        "ngrok|$HOME/work|ngrok start --all" \
        "specs-ui|$HOME/work|./scripts/start-specs-ui.sh"

    # --- arg parsing ---
    set -l services_only 0
    set -l check_only 0
    for arg in $argv
        switch $arg
            case --services-only -s
                set services_only 1
            case --check -c
                set check_only 1
            case --help -h
                echo "Usage: zw [--services-only|-s] [--check|-c]"
                echo "  (no args)         preconditions + open Zed + start all servers"
                echo "  --services-only   start servers only, no Zed window (used by the Zed task)"
                echo "  --check           run preconditions only (no side effects)"
                return 0
            case '*'
                echo "zw: unknown option '$arg' (try --help)" >&2
                return 2
        end
    end

    # --- precondition guard: fail fast, before any server spawns ---
    if not _zw_preconditions $settings
        return 1
    end
    if test $check_only -eq 1
        echo "zw: preconditions OK"
        return 0
    end

    # --- open the Zed work project (idempotent: focuses if already open) ---
    if test $services_only -eq 0
        echo "zw: opening Zed → $zed_paths"
        zed $zed_paths
    end

    # --- start servers: idempotent (skip live), non-fatal per server ---
    mkdir -p $state_dir
    set -l started # "name:pid" for just-launched servers
    set -l skipped # names already running
    set -l failed  # names that died on launch

    for entry in $servers
        set -l parts (string split -m2 '|' -- $entry)
        set -l name $parts[1]
        set -l cwd $parts[2]
        set -l cmd $parts[3]
        set -l pidfile $state_dir/$name.pid
        set -l logfile $state_dir/$name.log

        # already running? our pidfile + a live pid
        if test -f $pidfile
            set -l oldpid (cat $pidfile 2>/dev/null)
            if test -n "$oldpid"; and kill -0 $oldpid 2>/dev/null
                echo "• $name already running (pid $oldpid)"
                set -a skipped $name
                continue
            end
            rm -f $pidfile # stale
        end

        # start detached, log to file; one tracked pid per server
        nohup fish -c "cd $cwd && $cmd" >$logfile 2>&1 &
        set -l pid $last_pid
        echo $pid >$pidfile
        disown $pid 2>/dev/null
        set -a started "$name:$pid"
    end

    # --- grace check: catch servers that died immediately ---
    if test (count $started) -gt 0
        sleep 2
    end
    set -l ok
    for s in $started
        set -l parts (string split -m1 ':' -- $s)
        set -l name $parts[1]
        set -l pid $parts[2]
        if kill -0 $pid 2>/dev/null
            echo "✓ $name started (pid $pid)"
            set -a ok $name
        else
            echo "✗ $name FAILED — see $state_dir/$name.log"
            rm -f $state_dir/$name.pid
            set -a failed $name
        end
    end

    # --- summary (never blanket success when something failed) ---
    echo ""
    echo "zw: "(count $ok)" started, "(count $skipped)" already running, "(count $failed)" failed"
    if test (count $failed) -gt 0
        echo "zw: FAILED → $failed" >&2
        return 1
    end
    return 0
end

function _zw_preconditions --argument-names settings --description 'zw precondition guard'
    set -l ok 1
    if not command -q zed
        echo "zw: ✗ \`zed\` not on PATH" >&2
        set ok 0
    end
    if not test -f $settings
        echo "zw: ✗ Zed settings not found at $settings" >&2
        set ok 0
    else
        if not grep -q '"program": "fish"' $settings
            echo "zw: ✗ fish is not Zed's terminal shell (settings.json → terminal.shell.program)" >&2
            set ok 0
        end
        if not grep -q 'claude-acp' $settings
            echo "zw: ✗ no claude-acp ACP agent configured (settings.json → agent_servers)" >&2
            set ok 0
        end
    end
    test $ok -eq 1
end
