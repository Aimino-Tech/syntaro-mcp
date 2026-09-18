# WORKFLOWS — pending a maintainer push with `workflow` scope

The automation token that seeded this repo has `repo` scope but not
`workflow` scope, so `.github/workflows/` cannot be pushed by automation.
A maintainer (or any token with `workflow` scope) lands these in one minute:

**Via web UI:** open the repo → "Add file" → "Create new file" for each path
below, paste the content, commit to `main`. **Via CLI:**

```bash
git clone https://github.com/Aimino-Tech/syntaro-mcp.git
cd syntaro-mcp
# recreate the three files below, then:
git add .github/workflows && git commit -m "ci: enable CI + publish workflows" && git push
```

After that, delete this file (`docs/WORKFLOWS-PENDING.md`) in the same commit.

---

## File 1 — `.github/workflows/ci.yml`

Runs on every push/PR: byte-compile, secret sweep, manifest version sync,
skill license + registration check, SSE boot with `/health` probe, and
`node --check` on the npm wrapper.

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:

jobs:
  mcp:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install Python deps
        run: pip install -r requirements.txt
      - name: Byte-compile server
        run: python -m py_compile syntaro_mcp/server.py syntaro_mcp/handlers.py syntaro_mcp/agent_handlers.py workers/pipeline_client.py
      - name: No leaked secrets
        run: |
          ! grep -rniE "sk-|ghp_|gho_|xoxb-|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|AKIA[0-9A-Z]{16}" \
            syntaro_mcp workers skills server.json .mcp.json smithery.yaml || exit 1
      - name: Manifest versions in sync
        run: |
          node -e "
            const pkg=require('./package.json').version;
            const srv=require('./server.json').version;
            const mcp=require('./.mcp.json').server.version;
            const fs=require('fs');
            const sm=fs.readFileSync('smithery.yaml','utf8').match(/^version:\s*\"?([^\"\s]+)\"?/m)[1];
            for (const [f,v] of [['server.json',srv],['.mcp.json',mcp],['smithery.yaml',sm]])
              if (v!==pkg) { console.error(f+' version '+v+' != package.json '+pkg); process.exit(1); }
            console.log('versions in sync:', pkg);
          "
      - name: Skills licensed + registered
        run: |
          node -e "
            const fs=require('fs');
            const mp=JSON.parse(fs.readFileSync('.claude-plugin/marketplace.json','utf8'));
            const dirs=fs.readdirSync('skills',{withFileTypes:true}).filter(d=>d.isDirectory()).map(d=>d.name);
            const listed=mp.skills.map(s=>s.split('/')[1]).sort();
            if (JSON.stringify(listed)!==JSON.stringify([...dirs].sort())) { console.error('marketplace skills != skills/:', listed, dirs); process.exit(1); }
            for (const d of dirs) {
              const lic=fs.readFileSync('skills/'+d+'/SKILL.md','utf8').match(/^license:\s*(.+?)\s*$/m)?.[1].trim();
              if (lic!=='AGPL-3.0-only') { console.error(d+' license: '+lic); process.exit(1); }
            }
            console.log('skills ok:', dirs.join(','));
          "
      - name: SSE boots + /health answers
        run: |
          python -m syntaro_mcp.server sse --port 4095 &
          SRV=$!
          for i in $(seq 1 20); do curl -sf localhost:4095/health && break || sleep 1; done
          curl -sf localhost:4095/health | grep -q '"status":"ok"'
          kill $SRV
      - name: npm wrapper syntax
        run: node --check index.js
```

## File 2 — `.github/workflows/publish-npm.yml`

Publishes `@aimino/syntaro-mcp` on every `v*` tag. Needs the `NPM_TOKEN`
repo secret (npm access token, automation type).

```yaml
name: publish-npm
on:
  push:
    tags: ["v*"]
jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: https://registry.npmjs.org
      - name: Tag matches package.json
        run: |
          PKG=$(node -p "require('./package.json').version")
          [ "v$PKG" = "${GITHUB_REF_NAME}" ] || { echo "tag ${GITHUB_REF_NAME} != v$PKG"; exit 1; }
      - run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## File 3 — `.github/workflows/docker.yml`

Pushes the hosted image to GHCR on every `v*` tag (uses the default
`GITHUB_TOKEN` — no extra secret needed).

```yaml
name: docker
on:
  push:
    tags: ["v*"]
jobs:
  image:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ghcr.io/aimino-tech/syntaro-mcp:${{ github.ref_name }},ghcr.io/aimino-tech/syntaro-mcp:latest
```
