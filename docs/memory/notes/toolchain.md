# Toolchain on the owner's Mac (observed 2026-11-05)

- Flutter 3.47.7 stable, Dart 3.13.5, Android SDK 36. `flutter create --empty` works.
- Node via nvm: not on PATH in non-interactive shells; start every command with
  `source ~/.zshrc`. `npx supabase` resolves to CLI 3.0.0.
- Supabase CLI is not logged in: `npx supabase orgs list` returns AccessTokenRequiredError.
  `supabase login` is interactive (the owner runs it with `!` in the session), or set
  `SUPABASE_ACCESS_TOKEN` from the credentials file.
- Docker Desktop is installed at `~/.docker/bin/docker` and was running.
- `gh` is not installed; git pushes use the ssh remote.
- The other project's local Supabase stack uses ports 553xx; this one uses 563xx so both can
  run at once.
