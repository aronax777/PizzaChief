"""Validate captured real Studio client/server evidence; does not simulate gameplay."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
evidence = json.loads((ROOT / 'tests/multiplayer-session.json').read_text())
checks = []


def check(name, passed):
    checks.append({'name': name, 'passed': bool(passed)})


def rows(room):
    value = room['players']
    return list(value.values()) if isinstance(value, dict) else value


check('Real Studio multiplayer test API used', evidence['realNetworking'] and
      evidence['method'] == 'StudioTestService.ExecuteMultiplayerTestAsync(2)')
server = evidence.get('finalServer', {})
check('Server independently sees both network players', server.get('isServer') and len(server.get('players', [])) == 2)
cancelled = evidence.get('canceledCountdown', {})
check('Leaving countdown returns remaining player to waiting', cancelled.get('phase') == 'waiting'
      and cancelled.get('startsAt') == 0 and len(cancelled.get('players', [])) == 1)
for run_name in ('initialRun', 'finalRun'):
    run = evidence.get(run_name)
    check(f'{run_name}: captured', run is not None)
    if not run:
        continue
    a, b = run['p1'], run['p2']
    check(f'{run_name}: two distinct real clients', a['Identity']['id'] != b['Identity']['id']
          and a['Identity']['players'] == b['Identity']['players'] == 2)
    for round_no in (1, 2):
        start_a, start_b = a[f'Start{round_no}'], b[f'Start{round_no}']
        end_a, end_b = a[f'Result{round_no}'], b[f'Result{round_no}']
        prefix = f'{run_name}/round{round_no}'
        for field in ('recipeId', 'startedAt', 'deadline'):
            check(f'{prefix}: shared {field}', start_a[field] == start_b[field])
        check(f'{prefix}: full 90-second allowance', start_a['deadline'] - start_a['startedAt'] == 90)
        check(f'{prefix}: clean prep on both clients', all(s['phase'] == 'prep' and
              not s['ingredients'] and s.get('result') is None for s in (start_a, start_b)))
        check(f'{prefix}: identical final standings', end_a['room'] == end_b['room'])
        check(f'{prefix}: both served', all(r['done'] and not r['forfeited'] for r in rows(end_a['room'])))
        expected = a['Identity']['id'] if round_no == 1 else b['Identity']['id']
        check(f'{prefix}: expected winner', end_a['room']['winner']['userId'] == expected)
        for player_name, end in (('p1', end_a), ('p2', end_b)):
            result = end['result']
            check(f'{prefix}/{player_name}: score formula', abs(result['total'] -
                  (.8 * result['quality'] + .2 * result['speed'])) < 1e-8)
            check(f'{prefix}/{player_name}: server quality formula', abs(result['quality'] -
                  (.65 * result['recipeScore'] + .35 * result['bakeScore'])) < 1e-8)
    check(f'{run_name}: recipe rotates on rematch', a['Start1']['recipeId'] != a['Start2']['recipeId'])
    for player_name, player in run.items():
        check(f'{run_name}/{player_name}: one win each after rematch', player['Result2']['profile']['battleWins'] == 1)
        check(f'{run_name}/{player_name}: progress retained',
              player['Start2']['profile']['xp'] == player['Result1']['profile']['xp'] and
              player['Result2']['profile']['xp'] > player['Result1']['profile']['xp'])
        if 'TimeoutResult' in player:
            end = player['TimeoutResult']
            check(f'{run_name}/{player_name}: timeout finished without winner',
                  end['phase'] == 'result' and end['room']['phase'] == 'finished' and
                  end['room'].get('winner') is None and all(r['total'] == 0 for r in rows(end['room'])))
            check(f'{run_name}/{player_name}: timeout did not award a win', end['profile']['battleWins'] == 1)
            check(f'{run_name}/{player_name}: actual deadline reached', end['serverNow'] >= end['deadline'])

if 'finalRun' in evidence:
    check('Slow service reduces speed score over real network', evidence['finalRun']['p1']['Result2']['result']['speed'] < 90)
    waiting = evidence['finalRun']['p2'].get('Waiting2', {})
    check('Early finisher cannot rematch before opponent finishes',
          waiting.get('againActive') is False and waiting.get('state', {}).get('room', {}).get('phase') == 'active')
    for player, ui in evidence.get('rematchQueueUI', {}).items():
        check(f'{player}: immediate rematch queued on finished room', ui['state']['room']['phase'] == 'finished'
              and ui['state']['queued'] and ui['state']['room']['queuedCount'] == 2)
        check(f'{player}: rematch message is current', 'Готуємо наступний раунд' in ui['toast'])
    for player, ui in evidence.get('countdownUI', {}).items():
        check(f'{player}: stale countdown toast hidden', not ui['toastVisible'])
        check(f'{player}: legacy chat hidden', not ui['chatVisible'])

report = {
    'passed': all(c['passed'] for c in checks),
    'total': len(checks),
    'checks': checks,
    'sourceHashes': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                     for p in sorted((ROOT / 'src').rglob('*.luau'))},
}
(ROOT / 'tests/multiplayer-validation.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(f"{sum(c['passed'] for c in checks)}/{len(checks)} checks passed")
for c in checks:
    if not c['passed']:
        print('FAIL:', c['name'])
raise SystemExit(0 if report['passed'] else 1)
