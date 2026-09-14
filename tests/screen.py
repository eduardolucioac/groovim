import sys, re
raw = open(sys.argv[1], 'rb').read().decode('utf8', 'replace')
scr = [[' ']*110 for _ in range(30)]; r = c = i = 0
while i < len(raw):
    ch = raw[i]
    if ch == '\x1b':
        m = re.match(r'\x1b\[([0-9;]*)([A-Za-z])', raw[i:])
        if m:
            p, cmd = m.group(1), m.group(2)
            n = [int(x) if x else 0 for x in p.split(';')] if p else []
            if cmd == 'H': r = (n[0]-1 if n else 0); c = (n[1]-1 if len(n) > 1 else 0)
            elif cmd == 'K':
                for x in range(c, 110): scr[r][x] = ' '
            elif cmd == 'J':
                for y in range(30):
                    for x in range(110): scr[y][x] = ' '
            i += m.end(); continue
        mm = None
        for pat in (r'\x1b\][^\x07]*\x07', r'\x1bP.*?\x1b\\'):
            mm = re.match(pat, raw[i:], re.S)
            if mm: break
        if mm: i += mm.end(); continue
        i += 1; continue
    if ch == '\n': r += 1; c = 0
    elif ch == '\r': c = 0
    elif ch == '\x08': c = max(0, c-1)
    elif 0 <= r < 30 and 0 <= c < 110: scr[r][c] = ch; c += 1
    i += 1
for y in range(24):
    line = ''.join(scr[y]).rstrip()
    if line: print('  %2d| %s' % (y+1, line[:96]))
