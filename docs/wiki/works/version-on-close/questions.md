# Questions of version-on-close

| ID | Question | Recommendation | Blocks |
|----|----------|----------------|--------|
| version-on-close-Q4 | Which files get the new version? Each project declares it in its own files, and version-on-close-2 reads none to know whether it versions. | The files where the commit of the last version tag changed the old version, read with git. When there is no such file, ask the person. | Stage 3 |
| version-on-close-Q5 | Which forge gets the release, and how? | GitHub only for now, with `gh`, when the project's remote is on GitHub and `gh` is signed in. Otherwise the tag alone, and say so. | Stage 3 |

Q1 to Q3 were answered by version-on-close-2 to version-on-close-4.
