## 1. Implement Setup backup creation

- [x] 1.1 Update `setup.sh` to move existing target paths to `<name>.bak` if they exist.
- [x] 1.2 Update `setup.ps1` to move existing target paths to `<name>.bak` if they exist.

## 2. Implement Uninstall scripts

- [x] 2.1 Create `uninstall.sh` to remove global skill links, subagent links, and restore any `.bak` backups.
- [x] 2.2 Create `uninstall.ps1` to remove global skill junctions, copied subagent files, and restore any `.bak` backups.
- [x] 2.3 Create `uninstall.cmd` wrapper script for Windows.

## 3. Documentation

- [x] 3.1 Update `README.md` to document the new uninstall scripts.
