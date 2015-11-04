# vit

vit lets you use `git` commands with a `vim` mindset.

## ⚠ WORK IN PROGRESS ⚠

_I'm doing RDD (Readme driven development) here, so do not trust everything you
read, this is still under development and not production ready_

It adds a set of aliases inspired by `vim` to handle branches, commits, tags,
files and much more.

All commands follow the same pattern of `v{object}{action}`. For example `vbl`
will **l**ist all **b**ranches, while `vfa` will **a**dd a **f**ile to the
index.

## Commands

| command | Action                                              | 
| `vbM`   | Merge branch with specified one                     | 
| `vbRr`  | Remove specified remote branch                      | 
| `vbR`   | Remove specified branch                             | 
| `vbc`   | Create new branch                                   | 
| `vblr`  | **L**ist **r**emote **b**ranches                    | 
| `vbl`   | **L**ist local **b**ranches                         | 
| `vbmd`  | Rebase current branch with develop                  | 
| `vbmi`  | Interactive rebase up to specified ref              | 
| `vbmm`  | Rebase current branch with master                   | 
| `vbmv`  | Rename branch                                       | 
| `vbm`   | Rebase branch with specified one                    | 
| `vbpl`  | Pull (rebase) branch                                | 
| `vbpsf` | Push force branch                                   | 
| `vbps`  | Push branch                                         | 
| `vbsd`  | Switch to develop branch                            | 
| `vbsm`  | Switch to master branch                             | 
| `vbsq`  | Squash branch to specific ref                       | 
| `vbs`   | Switch current branch                               | 
| `vb.`   | Display current branch                              | 
| `vb?`   | Check is specified branch exists                    | 
| `vcRa`  | Remove all commits up to specified one              | 
| `vcR`   | Remove commit                                       | 
| `vca`   | Commit all files                                    | 
| `vcc`   | Commit current index                                | 
| `vce`   | Edit previous commit (and adds current index to it) | 
| `vcf`   | Find string in commit logs                          | 
| `vcl`   | List commits                                        | 
| `vcz`   | Cancel previous commit (think Ctrl-z)               | 
| `vc.`   | Display current commit                              | 
| `vdcl`  | Cancel all changes, revert to last commit           | 
| `vdc`   | Create new repository                               | 
| `vde`   | Edit repository config                              | 
| `vdr`   | Cd to repository root                               | 
| `vfa`   | Add file to index                                   | 
| `vfua`  | Unstage all files to index                          | 
| `vfu`   | Unstage file to index                               | 
| `vrea`  | Abort current rebase                                | 
| `vrec`  | Continue current rebase                             | 
| `vres`  | Skip current rebase                                 | 
| `vtRr`  | Remove specified remote tag                         | 
| `vtR`   | Remove specified tag                                | 
| `vtc`   | Create new branch                                   | 
| `vtlr`  | List remote tags                                    | 
| `vtl`   | List tags                                           | 
| `vt.`   | Display current tag                                 | 
| `vt?`   | Check is specified tag exists                       | 
